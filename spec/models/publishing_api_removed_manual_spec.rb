require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'
require 'gds_api/test_helpers/rummager'
require 'gds_api/test_helpers/content_store'

describe PublishingAPIRemovedManual do
  describe 'validations' do
    let(:slug) { 'our-slug' }
    subject(:removed_manual) { described_class.new(slug) }

    context 'validating slug format' do
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:slug) }
    end

    context 'checking that the manual exists already' do
      include GdsApi::TestHelpers::ContentStore

      let(:manual_path) { subject.base_path }

      it 'is invalid if the slug does not represent a piece of content' do
        content_store_does_not_have_item(manual_path)
        expect(subject).not_to be_valid
      end

      it 'is invalid if the slug already represents a "gone" piece of content' do
        content_item = content_item_for_base_path(manual_path).merge("format" => "gone")
        content_store_has_item(manual_path, content_item)
        expect(subject).not_to be_valid
      end

      it 'is valid when the slug represents an "hmrc-manual" piece of content' do
        content_item = hmrc_manual_content_item_for_base_path(manual_path)
        content_store_has_item(manual_path, content_item)
        expect(subject).to be_valid
      end

      it 'is invalid when the slug represents any other format piece of content' do
        content_store_has_item(manual_path)
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#to_h' do
    let(:removed_manual) { described_class.new('some-slug') }
    subject(:removed_manual_as_hash) { removed_manual.to_h }

    context 'valid schema' do
      it { should be_valid_against_schema('gone') }
    end

    it 'is a "gone" document type' do
      expect(subject[:document_type]).to eq('gone')
    end

    it 'is published by the "hmrc-manuals-api" app' do
      expect(subject[:publishing_app]).to eq('hmrc-manuals-api')
    end

    it 'has two routes' do
      expect(subject[:routes].size).to eq(2)
    end

    it 'includes the base_path of the manual as an exact path in routes' do
      expect(subject[:routes]).to include({ path: removed_manual.base_path, type: :exact })
    end

    it 'includes the updates_path of the manual as an exact path in routes' do
      expect(subject[:routes]).to include({ path: removed_manual.updates_path, type: :exact })
    end
  end

  describe '#sections' do
    subject(:removed_manual) { described_class.new('some-manual-slug') }

    it 'asks rummager for all the hmrc manual sections under its slug' do
      rummager_query = stub_request(:get, %r{/unified_search.json})
        .with(query: search_for_sections_rummager_query('some-manual-slug'))
        .to_return(body: no_manual_sections_rummager_json_result)

      subject.sections

      assert_requested rummager_query
    end

    it 'exposes each result from rummager as a PublishingAPIRemovedSection' do
      stub_request(:get, %r{/unified_search.json})
        .to_return(body: two_manual_sections_rummager_json_result('some-manual-slug'))

      sections = subject.sections
      expect(sections.size).to eq(2)

      expect(sections.first).to be_a PublishingAPIRemovedSection
      expect(sections.first.manual_slug).to eq('some-manual-slug')
      expect(sections.first.section_slug).to eq('section-1')

      expect(sections.last).to be_a PublishingAPIRemovedSection
      expect(sections.last.manual_slug).to eq('some-manual-slug')
      expect(sections.last.section_slug).to eq('section-2')
    end

    it 'exposes the error from rummager if the rummager call fails' do
      stub_request(:get, %r{/unified_search.json})
        .to_return(status: 503, body: '{"error":"arg!"}')

      expect {
        subject.sections
      }.to raise_error(GdsApi::BaseError)
    end
  end

  describe '#save!' do
    include GdsApi::TestHelpers::PublishingApiV2
    include GdsApi::TestHelpers::Rummager
    include GdsApi::TestHelpers::ContentStore
    before do
      content_item = hmrc_manual_content_item_for_base_path(subject.base_path)
      content_store_has_item(subject.base_path, content_item)
    end

    describe 'for an invalid manual' do
      subject(:removed_manual) { described_class.new('this_is_not_acc3ptABLE!') }

      it 'raises a validation error' do
        expect {
          subject.save!
        }.to raise_error(ValidationError)
      end

      it 'does not communicate with the publishing api' do
        publishing_api_stub = stub_any_publishing_api_call

        ignoring_error(ValidationError) { subject.save! }

        assert_not_requested publishing_api_stub
      end
    end

    describe 'for a valid manual' do
      subject(:removed_manual) { described_class.new('some-slug') }
      let(:publishing_api_base_path) { '/hmrc-internal-manuals/some-slug' }
      let(:gone_manual) { gone_manual_for_publishing_api(base_path: publishing_api_base_path) }

      it 'issues a put_content and publish requests to the publishing api to mark the manual as gone' do
        stub_publishing_api_put_content(removed_manual.content_id, {}, {status: 201, body: {version: 4}.to_json})
        stub_publishing_api_publish(removed_manual.content_id, { update_type: 'major', previous_version: 4}.to_json)
        stub_any_rummager_delete

        subject.save!

        assert_publishing_api_put_content(removed_manual.content_id, gone_manual)
        assert_publishing_api_publish(removed_manual.content_id, {update_type: 'major', previous_version: 4})

        #TODO: Update this with `assert_rummager_deleted_item(publishing_api_base_path[1..-1])`
        #      once https://github.com/alphagov/gds-api-adapters/pull/362 has been merged
        assert_requested(:delete, %r{#{Plek.new.find('rummager')}/documents/#{publishing_api_base_path}})
      end
    end
  end

  def hmrc_manual_content_item_for_base_path(base_path)
    content_item_for_base_path(base_path).merge("format" => MANUAL_FORMAT)
  end
end
