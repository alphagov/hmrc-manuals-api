require "rails_helper"
require "gds_api/test_helpers/publishing_api"

describe LinksBuilder do
  include LinksUpdateHelper

  describe "#build_links" do
    let(:content_id) { "document-uuid" }

    it "add HMRC content id as primary_publishing_organisation" do
      stub_publishing_api_get_links(content_id, body: { links: { "some_other_link" => "foo" } })
      expect(LinksBuilder.new(content_id).build_links).to eq(
        "organisations" => %w[6667cce2-e809-4e21-ae09-cb0bdc1ddda3],
        "primary_publishing_organisation" => %w[6667cce2-e809-4e21-ae09-cb0bdc1ddda3],
      )
    end

    context "document already has linked organisation" do
      before do
        stub_publishing_api_get_links(content_id, body: { links: { "organisations" => %w[some-org-uuid] } })
      end

      it "uses the existing organisation content ID" do
        expect(LinksBuilder.new(content_id).build_links).to eq(
          "organisations" => %w[some-org-uuid],
          "primary_publishing_organisation" => %w[6667cce2-e809-4e21-ae09-cb0bdc1ddda3],
        )
      end
    end

    context "document does not have linked organisation" do
      before do
        stub_publishing_api_get_links(content_id, body: { links: { "some_other_link" => "foo" } })
      end

      it "uses the default HMRC organisation content ID" do
        expect(LinksBuilder.new(content_id).build_links).to eq(
          "organisations" => %w[6667cce2-e809-4e21-ae09-cb0bdc1ddda3],
          "primary_publishing_organisation" => %w[6667cce2-e809-4e21-ae09-cb0bdc1ddda3],
        )
      end
    end

    context "no links found" do
      include GdsApi::TestHelpers::PublishingApi
      before do
        stub_publishing_api_does_not_have_links(content_id)
      end

      it "uses the default HMRC organisation content ID" do
        expect(LinksBuilder.new(content_id).build_links).to eq(
          "organisations" => %w[6667cce2-e809-4e21-ae09-cb0bdc1ddda3],
          "primary_publishing_organisation" => %w[6667cce2-e809-4e21-ae09-cb0bdc1ddda3],
        )
      end
    end
  end
end
