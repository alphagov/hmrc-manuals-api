require 'rails_helper'

describe LinksBuilder do
  describe "#build_links" do
    let(:content_id) { "document-uuid" }

    context "document already has linked organisation" do
      before do
        allow(Services.publishing_api).to receive(:get_links).with(content_id).and_return(
          { "organisations" => ["some-org-uuid"] }
        )
      end

      it "uses the existing organisation content ID" do
        expect(LinksBuilder.new(content_id).build_links).to eq(
          "organisations" => ["some-org-uuid"]
        )
      end
    end

    context "document does not have linked organisation" do
      before do
        allow(Services.publishing_api).to receive(:get_links).with(content_id).and_return(
          {}
        )
      end

      it "uses the default HMRC organisation content ID" do
        expect(LinksBuilder.new(content_id).build_links).to eq(
          "organisations" => ["6667cce2-e809-4e21-ae09-cb0bdc1ddda3"]
        )
      end
    end

    context "no document found" do
      before do
        allow(Services.publishing_api).to receive(:get_links).with(content_id).and_raise(GdsApi::HTTPNotFound.new(404, 'some', 'error'))
      end

      it "uses the default HMRC organisation content ID" do
        expect(LinksBuilder.new(content_id).build_links).to eq(
          "organisations" => ["6667cce2-e809-4e21-ae09-cb0bdc1ddda3"]
        )
      end
    end
  end
end
