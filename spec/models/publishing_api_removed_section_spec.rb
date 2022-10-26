require "rails_helper"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/search"
require "gds_api/test_helpers/content_store"

describe PublishingAPIRemovedSection do
  describe ".from_search_api_result" do
    let(:search_api_json) { single_section_parsed_search_api_json_result("manual-slug", "section-slug") }

    it "extracts the manual and section slugs from the link attribute" do
      section = described_class.from_search_api_result(search_api_json)
      expect(section).to be_a described_class
      expect(section.manual_slug).to eq("manual-slug")
      expect(section.section_slug).to eq("section-slug")
    end

    it "raises an InvalidJSONError if the json object has no link attribute" do
      expect {
        described_class.from_search_api_result(search_api_json.except("link"))
      }.to raise_error(InvalidJSONError)
    end

    it "raises an InvalidPathError if the link attribute cannot be used to extract slugs" do
      expect {
        described_class.from_search_api_result(search_api_json.merge("link" => "/oh-my/what-a-hat/"))
      }.to raise_error(InvalidPathError)
    end
  end

  describe "validations" do
    let(:manual_slug) { "a-manual" }
    let(:section_slug) { "a-section" }
    subject(:removed_manual) { described_class.new(manual_slug, section_slug) }

    context "validating slug format" do
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:manual_slug) }
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:section_slug) }
    end

    context "checking that the manual section exists already" do
      include GdsApi::TestHelpers::ContentStore

      let(:section_path) { subject.base_path }

      it "is invalid if the slugs do not represent a piece of content" do
        stub_content_store_does_not_have_item(section_path)
        expect(subject).not_to be_valid
      end

      it 'is invalid if the slugs already represent a "gone" piece of content' do
        content_item = content_item_for_base_path(section_path).merge("format" => "gone")
        stub_content_store_has_item(section_path, content_item)
        expect(subject).not_to be_valid
      end

      it 'is valid when the slugs represent an "hmrc-manual-section" piece of content' do
        content_item = hmrc_manual_section_content_item_for_base_path(section_path)
        stub_content_store_has_item(section_path, content_item)
        expect(subject).to be_valid
      end

      it "is invalid when the slugs represents a piece of content with any other schema_name" do
        stub_content_store_has_item(section_path)
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#to_h" do
    let(:removed_manual_section) { described_class.new("some-manual", "some-section") }
    subject(:removed_manual_section_as_hash) { removed_manual_section.to_h }

    context "valid schema" do
      it { should be_valid_against_publisher_schema("gone") }
    end

    it 'is a "gone" document type' do
      expect(subject[:document_type]).to eq("gone")
    end

    it 'is published by the "hmrc-manuals-api" app' do
      expect(subject[:publishing_app]).to eq("hmrc-manuals-api")
    end

    it "has one routes" do
      expect(subject[:routes].size).to eq(1)
    end

    it "includes the base_path of the manual section as an exact path in routes" do
      expect(subject[:routes]).to include(path: removed_manual_section.base_path, type: :exact)
    end
  end

  describe "#save!" do
    include GdsApi::TestHelpers::PublishingApi
    include GdsApi::TestHelpers::ContentStore
    before do
      content_item = hmrc_manual_section_content_item_for_base_path(subject.base_path)
      stub_content_store_has_item(subject.base_path, content_item)
    end

    describe "for an invalid manual section" do
      subject(:removed_manual_section) { described_class.new("this_is_not_acc3ptABLE!", "is it?") }

      it "raises a validation error" do
        expect {
          subject.save!
        }.to raise_error(ValidationError)
      end

      it "does not communicate with the publishing api" do
        publishing_api_stub = stub_any_publishing_api_put_content

        ignoring_error(ValidationError) { subject.save! }

        assert_not_requested publishing_api_stub
      end
    end

    describe "for a valid manual section" do
      subject(:removed_manual_section) { described_class.new("some-manual", "some-section") }
      let(:publishing_api_base_path) { "/hmrc-internal-manuals/some-manual/some-section" }

      it "issues put_content and publish requests to the publishing api to mark the manual section as gone" do
        stub_publishing_api_put_content(removed_manual_section.content_id, {}, body: { version: 33 })
        stub_publishing_api_publish(removed_manual_section.content_id, { update_type: nil, previous_version: 33 }.to_json)

        subject.save!

        assert_publishing_api_put_content(removed_manual_section.content_id, gone_manual_section_for_publishing_api)
        assert_publishing_api_publish(
          removed_manual_section.content_id,
          update_type: nil,
          previous_version: 33,
        )
      end
    end
  end

  def hmrc_manual_section_content_item_for_base_path(base_path)
    content_item_for_base_path(base_path).merge("schema_name" => SECTION_SCHEMA_NAME)
  end
end
