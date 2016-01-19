require 'rails_helper'

describe PublishingAPINotifier do
  describe '#notify' do
    let(:content_id) { 'de305d54-75b4-431b-adb2-eb6b9e546014' }
    let(:document_hash) { {'a' => '1'} }
    let(:document) { double PublishingAPIManual, content_id: content_id, to_h: document_hash, update_type: 'major' }
    let(:successful_response) { double "response", version: 33 }

    it "updates and publishes via the publishing API"   do
      expect(Services.publishing_api).to receive(:put_content).with(content_id, document_hash)
        .and_return(successful_response)
      expect(Services.publishing_api).to receive(:publish).with(content_id, 'major', {previous_version: 33})

      PublishingAPINotifier.new(document).notify
    end
  end
end
