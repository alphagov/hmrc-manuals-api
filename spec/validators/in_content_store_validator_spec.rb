require "rails_helper"
require "gds_api/test_helpers/content_store"

describe InContentStoreValidator do
  include GdsApi::TestHelpers::ContentStore

  subject do
    InContentStoreValidator.new(
      content_store:,
      schema_names:,
    )
  end
  let(:content_store) { Services.content_store }
  let(:schema_names) { [MANUAL_SCHEMA_NAME, "redirect"] }

  let(:manual) { PublishingAPIManual.new(slug, attributes) }
  let(:slug) { "some-slug" }
  let(:attributes) { valid_manual }
  let(:content_item_schema_name) { MANUAL_SCHEMA_NAME }

  before do
    stub_content_store_has_item("/hmrc-internal-manuals/#{slug}",
                                content_item_for_base_path("/hmrc-internal-manuals/#{slug}").merge(schema_name: content_item_schema_name))
  end

  context "with a matching schema name" do
    it "returns no errors" do
      expect(subject.validate(manual)).to be_nil
    end
  end

  context "with an invalid schema name" do
    let(:content_item_schema_name) { "invalid-schema-name" }
    it "returns an error" do
      expect(subject.validate(manual).attribute).to eq(:base)
      expect(subject.validate(manual).type).to eq("Exists in the content store, but is not a \"#{MANUAL_SCHEMA_NAME},redirect\" schema (it's a \"invalid-schema-name\" schema)")
    end
  end

  context "with a content item that does not exist" do
    before do
      stub_content_store_does_not_have_item("/hmrc-internal-manuals/#{slug}")
    end

    it "returns an error" do
      expect(subject.validate(manual).attribute).to eq(:base)
      expect(subject.validate(manual).type).to eq("Is not a manual in the content store")
    end
  end

  context "with a content item that is gone" do
    before do
      stub_content_store_has_gone_item("/hmrc-internal-manuals/#{slug}")
    end

    it "returns an error" do
      expect(subject.validate(manual).attribute).to eq(:base)
      expect(subject.validate(manual).type).to eq("Exists in the content store, but is already \"gone\"")
    end
  end

  context "without a value for schema_name" do
    let(:schema_names) { nil }

    it "raises an error" do
      expect { subject }.to raise_error(RuntimeError, "Must provide schema_names and content_store options to the validator")
    end
  end

  context "without a value for content_store" do
    let(:content_store) { nil }

    it "raises an error" do
      expect { subject }.to raise_error(RuntimeError, "Must provide schema_names and content_store options to the validator")
    end
  end

  context "with 'gone' as one of the schema_names" do
    let(:schema_names) { %w[gone] }

    it "raises an error" do
      expect { subject }.to raise_error(RuntimeError, "Can't provide \"gone\" as schema_names to the validator")
    end
  end
end
