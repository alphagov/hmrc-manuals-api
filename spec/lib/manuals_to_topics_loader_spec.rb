require 'spec_helper'
require 'manuals_to_topics_loader'

describe ManualsToTopicsLoader do
  let(:loader) { ManualsToTopicsLoader.new(csv_data) }

  let(:csv_data) {
    <<-EOS.strip
manual slug,topic slugs,topic ids
#{manual_with_one_topic},a-topic/sub-topic,#{topic_id_a}
#{manual_with_multiple_topics},"a-topic/sub-topic,another-topic/sub-topic","#{topic_id_a},#{topic_id_b}"
    EOS
  }

  let(:manual_with_one_topic) { 'manual-0' }
  let(:manual_with_multiple_topics) { 'manual-1' }

  let(:topic_id_a) { 'aaaa1111-1111-1aaa-aaaa-111111111111' }
  let(:topic_id_b) { 'bbbb2222-2222-2bbb-bbbb-222222222222' }

  describe '#load' do
    it 'returns a hash' do
      expect(loader.load).to be_a(Hash)
    end

    it 'returns the correct number of manuals' do
      expect(loader.load.size).to eq(2)
    end

    context 'manual with one topic' do
      let(:hash) { loader.load }
      let(:content_ids) { hash[manual_with_one_topic] }

      it 'has corrent topic content_id' do
        expect(content_ids).to eq(
          [
            topic_id_a,
          ]
        )
      end
    end

    context 'manual with multiple topics' do
      let(:hash) { loader.load }
      let(:content_ids) { hash[manual_with_multiple_topics] }

      it 'has correct topic content_ids' do
        expect(content_ids).to eq(
          [
            topic_id_a,
            topic_id_b,
          ]
        )
      end
    end
  end
end
