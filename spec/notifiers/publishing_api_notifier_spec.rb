require 'rails_helper'
describe PublishingAPINotifier do
  describe '#notify' do
    let(:content_id) { 'de305d54-75b4-431b-adb2-eb6b9e546014' }
    let(:document_hash) { {'a' => '1'} }
    let(:links_hash) { {links: { topics: %w(link1 link2 link3) } } }
    let(:document) { double PublishingAPIManual, content_id: content_id, to_h: document_hash, update_type: 'major', send_topic_links?: true, topic_links: links_hash }
    let(:successful_response) { OpenStruct.new(code: 200, version: 33) }
    let(:conflict_response) { OpenStruct.new(code: 409) }
    let(:unprocessable_response) { OpenStruct.new(code: 409) }

    context 'all requests get a 200 response' do
      it 'calls put_content, publish and send links and return a 200 response' do
        expect(Services.publishing_api).to receive(:put_content).with(content_id, document_hash).and_return(successful_response)
        expect(Services.publishing_api).to receive(:publish).with(content_id, 'major', {previous_version: 33}).and_return(successful_response)
        expect(Services.publishing_api).to receive(:put_links).with(content_id, links_hash).and_return(successful_response)

        response = PublishingAPINotifier.new(document).notify
        expect(response).to eq successful_response
      end

      it 'does not send links if no links to send' do
        document = double PublishingAPIManual, content_id: content_id, to_h: document_hash, update_type: 'major', send_topic_links?: false, topic_links: links_hash
        expect(Services.publishing_api).to receive(:put_content).with(content_id, document_hash).and_return(successful_response)
        expect(Services.publishing_api).to receive(:publish).with(content_id, 'major', {previous_version: 33}).and_return(successful_response)
        expect(Services.publishing_api).not_to receive(:put_links)

        response = PublishingAPINotifier.new(document).notify
        expect(response).to eq successful_response
      end
    end
  end
end
