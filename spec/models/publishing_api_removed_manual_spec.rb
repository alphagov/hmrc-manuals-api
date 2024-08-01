require "rails_helper"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/search"
require "gds_api/test_helpers/content_store"

describe PublishingAPIRemovedManual do
  describe "validations" do
    let(:slug) { "our-slug" }
    subject(:removed_manual) { described_class.new(slug) }

    context "validating slug format" do
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:slug) }
    end

    context "checking that the manual exists already" do
      include GdsApi::TestHelpers::ContentStore

      let(:manual_path) { subject.base_path }

      it "is invalid if the slug does not represent a piece of content" do
        stub_content_store_does_not_have_item(manual_path)
        expect(subject).not_to be_valid
      end

      it 'is invalid if the slug already represents a "gone" piece of content' do
        content_item = content_item_for_base_path(manual_path).merge("format" => "gone")
        stub_content_store_has_item(manual_path, content_item)
        expect(subject).not_to be_valid
      end

      it 'is valid when the slug represents an "hmrc-manual" piece of content' do
        content_item = hmrc_manual_content_item_for_base_path(manual_path)
        stub_content_store_has_item(manual_path, content_item)
        expect(subject).to be_valid
      end

      it 'is valid when the slugs represent a "redirect" piece of content' do
        content_item = hmrc_manual_content_item_for_base_path(manual_path).merge("schema_name" => "redirect")
        stub_content_store_has_item(manual_path, content_item)
        expect(subject).to be_valid
      end

      it "is invalid when the slug represents a piece of content with any other schema_name" do
        stub_content_store_has_item(manual_path)
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#to_h" do
    let(:removed_manual) { described_class.new("some-slug") }
    subject(:removed_manual_as_hash) { removed_manual.to_h }

    context "valid schema" do
      it { should be_valid_against_publisher_schema("gone") }
    end

    it 'is a "gone" document type' do
      expect(subject[:document_type]).to eq("gone")
    end

    it 'is published by the "hmrc-manuals-api" app' do
      expect(subject[:publishing_app]).to eq("hmrc-manuals-api")
    end

    it "has two routes" do
      expect(subject[:routes].size).to eq(2)
    end

    it "includes the base_path of the manual as an exact path in routes" do
      expect(subject[:routes]).to include(path: removed_manual.base_path, type: :exact)
    end

    it "includes the updates_path of the manual as an exact path in routes" do
      expect(subject[:routes]).to include(path: removed_manual.updates_path, type: :exact)
    end
  end

  describe "#sections" do
    subject(:removed_manual) { described_class.new("some-manual-slug") }

    it "asks Search API for all the hmrc manual sections under its slug" do
      search_api_query = stub_request(:get, %r{/search.json})
        .to_return(body: no_manual_sections_search_api_json_result)

      subject.sections

      assert_requested search_api_query
    end

    it "exposes each result from Search API as a PublishingAPIRemovedSection" do
      stub_request(:get, %r{/search.json})
        .to_return(body: two_manual_sections_search_api_json_result("some-manual-slug"))

      sections = subject.sections
      expect(sections.size).to eq(2)

      expect(sections.first).to be_a PublishingAPIRemovedSection
      expect(sections.first.manual_slug).to eq("some-manual-slug")
      expect(sections.first.section_slug).to eq("section-1")

      expect(sections.last).to be_a PublishingAPIRemovedSection
      expect(sections.last.manual_slug).to eq("some-manual-slug")
      expect(sections.last.section_slug).to eq("section-2")
    end

    it "exposes the error from Search API if the Search API call fails" do
      stub_request(:get, %r{/search.json})
        .to_return(status: 503, body: '{"error":"arg!"}')

      expect {
        subject.sections
      }.to raise_error(GdsApi::BaseError)
    end

    describe "paging through sections" do
      subject(:removed_manual) { described_class.new("some-manual-slug") }

      it "gets all sections when there is more than one page of results" do
        stub_request(:get, %r{/search.json?.+start=0})
          .to_return(body: one_of_two_manual_sections_search_api_json_result("some-manual-slug"))

        stub_request(:get, %r{/search.json?.+start=1})
          .to_return(body: two_of_two_manual_sections_search_api_json_result("some-manual-slug"))

        sections = subject.sections
        expect(sections.size).to eq(2)

        expect(sections.first).to be_a PublishingAPIRemovedSection
        expect(sections.first.manual_slug).to eq("some-manual-slug")
        expect(sections.first.section_slug).to eq("section-1")

        expect(sections.last).to be_a PublishingAPIRemovedSection
        expect(sections.last.manual_slug).to eq("some-manual-slug")
        expect(sections.last.section_slug).to eq("section-2")
      end
    end
  end

  describe "#save!" do
    include GdsApi::TestHelpers::PublishingApi
    include GdsApi::TestHelpers::ContentStore
    before do
      content_item = hmrc_manual_content_item_for_base_path(subject.base_path)
      stub_content_store_has_item(subject.base_path, content_item)
    end

    describe "for an invalid manual" do
      subject(:removed_manual) { described_class.new("this_is_not_acc3ptABLE!") }

      it "raises a validation error" do
        expect {
          subject.save!
        }.to raise_error(ValidationError)
      end

      it "does not communicate with the publishing api" do
        publishing_api_stub = stub_any_publishing_api_call

        ignoring_error(ValidationError) { subject.save! }

        assert_not_requested publishing_api_stub
      end
    end

    describe "for a valid manual" do
      subject(:removed_manual) { described_class.new("some-slug") }
      let(:publishing_api_base_path) { "/hmrc-internal-manuals/some-slug" }
      let(:gone_manual) { gone_manual_for_publishing_api(base_path: publishing_api_base_path) }

      it "issues a put_content and publish requests to the publishing api to mark the manual as gone" do
        stub_publishing_api_put_content(removed_manual.content_id, {}, status: 201, body: { version: 4 }.to_json)
        stub_publishing_api_publish(removed_manual.content_id, { update_type: nil, previous_version: 4 }.to_json)

        subject.save!

        assert_publishing_api_put_content(removed_manual.content_id, gone_manual)
        assert_publishing_api_publish(removed_manual.content_id, update_type: nil, previous_version: 4)
      end
    end
  end

  def hmrc_manual_content_item_for_base_path(base_path)
    content_item_for_base_path(base_path).merge("schema_name" => MANUAL_SCHEMA_NAME)
  end
end
