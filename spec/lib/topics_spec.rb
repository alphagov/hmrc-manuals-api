require 'rails_helper'
require 'topics'
require 'gds_api/test_helpers/content_register'

describe Topics do
  include GdsApi::TestHelpers::ContentRegister

  context 'with no topics' do
    let(:topics) {
      Topics.new(
        manual_slug: manual_slug,
        manuals_to_topics: manuals_to_topics,
      )
    }

    let(:manual_slug) { 'topicless-manual' }
    let(:manuals_to_topics) { {} }

    describe '#content_ids' do
      it 'returns an empty array' do
        expect(topics.content_ids).to eq([])
      end
    end

    describe '#slugs' do
      it 'returns an empty array' do
        expect(topics.slugs).to eq([])
      end
    end
  end

  context 'with topics' do
    let(:topics) {
      Topics.new(
        manual_slug: manual_slug,
        manuals_to_topics: manuals_to_topics,
        content_register: content_register,
      )
    }

    let(:a_content_id) { 'a-content-id' }
    let(:a_slug) { 'business-tax/vat' }

    let(:manual_slug) { 'topicful-manual' }
    let(:manuals_to_topics) {
      {
        manual_slug => [
          a_content_id,
        ]
      }
    }

    let(:content_register) {
      double(entries:
        [
          {
            'content_id' => a_content_id,
            'title' => 'VAT',
            'format' => 'topic',
            'base_path' => "/topic/#{a_slug}",
          },
          {
            'content_id' => 'another-content-id',
            'title' => 'PAYE',
            'format' => 'topic',
            'base_path' => '/topic/business-tax/paye',
          },
        ],
      )
    }

    describe '#content_ids' do
      it 'returns the content_ids' do
        expect(topics.content_ids).to eq([a_content_id])
      end
    end

    describe '#slugs' do
      it 'returns the slugs' do
        expect(topics.slugs).to eq([a_slug])
      end
    end
  end

  context 'when content register is unavailable' do
    let(:topics) {
      Topics.new(
        manual_slug: manual_slug,
        manuals_to_topics: manuals_to_topics,
      )
    }

    let(:a_content_id) { 'a-content-id' }

    let(:manual_slug) { 'topicful-manual' }
    let(:manuals_to_topics) {
      {
        manual_slug => [
          a_content_id,
        ]
      }
    }

    before do
      content_register_isnt_available
    end

    describe '#content_ids' do
      it 'returns the content_ids' do
        expect(topics.content_ids).to eq([a_content_id])
      end
    end

    describe '#slugs' do
      it 're-raises GdsApi::HTTPServerError' do
        expect {
          topics.slugs
        }.to raise_error(GdsApi::HTTPServerError)
      end
    end
  end
end
