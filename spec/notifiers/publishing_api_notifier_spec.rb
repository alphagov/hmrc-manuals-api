require "rails_helper"

describe PublishingAPINotifier do
  describe "#notify" do
    let(:content_id) { "de305d54-75b4-431b-adb2-eb6b9e546014" }
    let(:document_hash) { { "a" => "1" } }
    let(:document) do
      double PublishingAPIManual,
             content_id:,
             to_h: document_hash,
             update_type: "major",
             links: { "some" => "linked_data" }
    end
    let(:successful_response) do
      { "version" => 33 }
    end

    it "makes calls to update the document, publish it, and update its links via the publishing API" do
      expect(Services.publishing_api).to receive(:put_content).with(content_id, document_hash)
        .and_return(successful_response)
      expect(Services.publishing_api).to receive(:publish).with(content_id, nil, previous_version: 33)
      expect(Services.publishing_api).to receive(:patch_links).with(content_id, links: { "some" => "linked_data" })

      PublishingAPINotifier.new(document).notify
    end

    context "we ask not to update links" do
      it "updates and publishes the document, but doesn't update the links" do
        expect(Services.publishing_api).to receive(:put_content).with(content_id, document_hash)
          .and_return(successful_response)
        expect(Services.publishing_api).to receive(:publish).with(content_id, nil, previous_version: 33)
        expect(Services.publishing_api).to_not receive(:patch_links)

        PublishingAPINotifier.new(document).notify(update_links: false)
      end
    end
  end
end
