require 'spec_helper'
require 'manuals_topics_content_ids_loader'

describe ManualsTopicsContentIdsLoader do
  let(:loader) { ManualsTopicsContentIdsLoader.new(csv_data) }

  let(:csv_data) {
    <<-EOS.strip
manual slug,topic slugs,topic ids
#{manual_with_one_topic},topics/topic-a,topic-a
#{manual_with_multiple_topics},"topics/topic-a,topics/topic-b","topic-a,topic-b"
    EOS
  }

  let(:manual_with_one_topic) { "manuals/manual-0" }
  let(:manual_with_multiple_topics) { "manuals/manual-1" }

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

      it 'has 1 topic content_id' do
        expect(content_ids.size).to eq(1)
      end
    end

    context 'manual with multiple topics' do
      let(:hash) { loader.load }
      let(:content_ids) { hash[manual_with_multiple_topics] }

      it 'has multiple topic content_ids' do
        expect(content_ids.size).to be > 1
      end
    end
  end
end
