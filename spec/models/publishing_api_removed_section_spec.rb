require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

describe PublishingAPIRemovedSection do
  describe '.from_rummager_result' do
    let(:rummager_json) { single_section_parsed_rummager_json_result('manual-slug', 'section-slug') }

    it 'extracts the manual and section slugs from the link attribute' do
      section = described_class.from_rummager_result(rummager_json)
      expect(section).to be_a described_class
      expect(section.manual_slug).to eq('manual-slug')
      expect(section.section_slug).to eq('section-slug')
    end

    it 'raises an InvalidJSONError if the json object has no link attribute' do
      expect {
        described_class.from_rummager_result(rummager_json.except('link'))
      }.to raise_error(InvalidJSONError)
    end

    it 'raises an InvalidPathError if the link attribute cannot be used to extract slugs' do
      expect {
        described_class.from_rummager_result(rummager_json.merge('link' => '/oh-my/what-a-hat/'))
      }.to raise_error(InvalidPathError)
    end
  end

  describe 'validations' do
    context 'on section_slug' do
      it 'is invalid when it is missing' do
        expect(described_class.new('a-manual-slug', nil)).not_to be_valid
      end

      it 'is invalid when it does not match the valid_slug/pattern' do
        expect(described_class.new('a-manual-sug', "1Som\nSłu9G!")).not_to be_valid
      end
    end

    context 'on manual_slug' do
      it 'is invalid when it is missing' do
        expect(described_class.new(nil, 'a-section-slug')).not_to be_valid
      end

      it 'is invalid when it does not match the valid_slug/pattern' do
        expect(described_class.new("1Som\nSłu9G!", 'a-section-slug')).not_to be_valid
      end
    end
  end

  describe '#to_h' do
    let(:removed_manual_section) { described_class.new('some-manual', 'some-section') }
    subject(:removed_manual_section_as_hash) { removed_manual_section.to_h }

    it 'is a "gone" format object' do
      expect(subject[:format]).to eq('gone')
    end

    it 'is published by the "hmrc-manuals-api" app' do
      expect(subject[:publishing_app]).to eq('hmrc-manuals-api')
    end

    it 'is a major update' do
      expect(subject[:update_type]).to eq('major')
    end

    it 'has one routes' do
      expect(subject[:routes].size).to eq(1)
    end

    it 'includes the base_path of the manual section as an exact path in routes' do
      expect(subject[:routes]).to include({ path: removed_manual_section.base_path, type: :exact })
    end
  end

  describe '#save!' do
    include GdsApi::TestHelpers::PublishingApi

    describe 'for an invalid manual section' do
      subject(:removed_manual_section) { described_class.new('this_is_not_acc3ptABLE!', 'is it?') }

      it 'raises a validation error' do
        expect {
          subject.save!
        }.to raise_error(ValidationError)
      end

      it 'does not communicate with the publishing api' do
        publishing_api_stub = stub_default_publishing_api_put

        ignoring_error(ValidationError) { subject.save! }

        assert_not_requested publishing_api_stub
      end
    end

    describe 'for a valid manual section' do
      subject(:removed_manual_section) { described_class.new('some-manual', 'some-section') }
      let(:publishing_api_base_path) { '/hmrc-internal-manuals/some-manual/some-section' }

      it 'issues a put_item request to the publishing api to mark the manual section as gone' do
        stub_default_publishing_api_put

        subject.save!

        assert_publishing_api_put_item(publishing_api_base_path, gone_manual_section_for_publishing_api)
      end
    end
  end
end
