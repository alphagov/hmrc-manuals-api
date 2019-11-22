require "rails_helper"
require "gds_api/test_helpers/publishing_api_v2"
require "gds_api/test_helpers/search"
require "gds_api/test_helpers/content_store"

describe PublishingAPIRedirectedSection do
  include GdsApi::TestHelpers::ContentStore

  describe "validations" do
    let(:manual_slug) { "manual" }
    let(:section_slug) { "section" }
    let(:destination_manual_slug) { "redirect-manual" }
    let(:destination_section_slug) { "redirect-section" }
    subject(:redirected_manual) { described_class.new(manual_slug, section_slug, destination_manual_slug, destination_section_slug) }

    context "validating slug format" do
      before { stub_request(:any, %r{\A#{content_store_endpoint}}).to_return(status: 404, body: "{}") }
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:manual_slug) }
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:section_slug) }
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:destination_manual_slug) }
      it { should allow_value(nil).for(:destination_section_slug) }
      it { should_not allow_value("1Som\nSłu9G!").for(:destination_section_slug) }
    end

    context "checking that the manual section exists already" do
      let(:section_path) { subject.base_path }

      it "is invalid if the slugs do not represent a piece of content" do
        content_store_does_not_have_item(section_path)
        expect(subject).not_to be_valid
      end

      it 'is invalid if the slugs already represent a "gone" piece of content' do
        content_item = content_item_for_base_path(section_path).merge("format" => "gone")
        content_store_has_item(section_path, content_item)
        expect(subject).not_to be_valid
      end

      it 'is valid when the slugs represent an "hmrc-manual-section" piece of content' do
        content_item = hmrc_manual_section_content_item_for_base_path(section_path)
        content_store_has_item(section_path, content_item)
        expect(subject).to be_valid
      end

      it "is invalid when the slugs represent any other format piece of content" do
        content_store_has_item(section_path)
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#redirect_to_location" do
    context "for a redirect to another manual section" do
      it "is the path to the manual section" do
        redirect_to_location = described_class.new("old-manual", "old-section", "redirect-manual", "redirect-section").redirect_to_location
        expect(redirect_to_location).to eql("/hmrc-internal-manuals/redirect-manual/redirect-section")
      end
    end

    context "for a redirect to another manual" do
      it "is the path to the manual section" do
        redirect_to_location = described_class.new("old-manual", "old-section", "redirect-manual").redirect_to_location
        expect(redirect_to_location).to eql("/hmrc-internal-manuals/redirect-manual")
      end
    end
  end

  describe "#to_h" do
    let(:redirected_manual_section) { described_class.new("some-manual", "some-section", "manual-redirect", "section-redirect") }
    subject(:redirected_manual_section_as_hash) { redirected_manual_section.to_h }

    context "valid schema" do
      it { should be_valid_against_schema("redirect") }
    end

    it 'is a "redirect" document type' do
      expect(subject[:document_type]).to eq("redirect")
    end

    it 'is published by the "hmrc-manuals-api" app' do
      expect(subject[:publishing_app]).to eq("hmrc-manuals-api")
    end
  end

  describe "#save!" do
    include GdsApi::TestHelpers::PublishingApiV2
    include GdsApi::TestHelpers::Search

    before do
      content_item = hmrc_manual_section_content_item_for_base_path(subject.base_path)
      content_store_has_item(subject.base_path, content_item)
    end

    describe "for an invalid manual section" do
      subject(:removed_manual_section) { described_class.new("this_is_not_acc3ptABLE!", "is it?", "redirect_manual_slug", "redirect_section_slug") }

      it "raises a validation error" do
        expect { subject.save! }.to raise_error(ValidationError)
      end

      it "does not communicate with the publishing api" do
        publishing_api_stub = stub_any_publishing_api_put_content

        ignoring_error(ValidationError) { subject.save! }

        assert_not_requested publishing_api_stub
      end
    end

    describe "for a valid manual section" do
      context "being redirected to another manual section" do
        subject(:redirected_manual_section) { described_class.new("some-manual", "some-section", "some-other-manual", "some-other-section") }

        it "issues put_content and publish requests to the publishing api to mark the manual section as redirected" do
          stub_publishing_api_put_content(redirected_manual_section.content_id, {}, body: { version: 33 })
          stub_publishing_api_publish(redirected_manual_section.content_id, { update_type: nil, previous_version: 33 }.to_json)

          subject.save!

          assert_publishing_api_put_content(redirected_manual_section.content_id, redirected_manual_section_to_other_manual_section_for_publishing_api)
          assert_publishing_api_publish(redirected_manual_section.content_id, update_type: nil, previous_version: 33)
        end
      end

      context "being redirected to another manual" do
        subject(:redirected_manual_section) { described_class.new("some-manual", "some-section", "some-other-manual") }

        it "issues put_content and publish requests to the publishing api to mark the manual section as redirected" do
          stub_publishing_api_put_content(redirected_manual_section.content_id, {}, body: { version: 33 })
          stub_publishing_api_publish(redirected_manual_section.content_id, { update_type: nil, previous_version: 33 }.to_json)

          subject.save!

          assert_publishing_api_put_content(redirected_manual_section.content_id, redirected_manual_section_to_other_manual_for_publishing_api)
          assert_publishing_api_publish(redirected_manual_section.content_id, update_type: nil, previous_version: 33)
        end
      end
    end
  end

  def hmrc_manual_section_content_item_for_base_path(base_path)
    content_item_for_base_path(base_path).merge("schema_name" => SECTION_SCHEMA_NAME)
  end
end
