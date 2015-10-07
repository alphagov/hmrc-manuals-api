require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'


describe PublishingAPIRemovedManual do
  describe 'validations' do
    it 'is invalid without a slug' do
      expect(described_class.new(nil)).not_to be_valid
    end

    it 'is invalid with a slug that does not match the valid_slug/pattern' do
      expect(described_class.new("1Som\nSłu9G!")).not_to be_valid
    end
  end

  describe '#to_h' do
    let(:removed_manual) { described_class.new('some-slug') }
    subject(:removed_manual_as_hash) { removed_manual.to_h }

    it 'is a "gone" format object' do
      expect(subject[:format]).to eq('gone')
    end

    it 'is published by the "hmrc-manuals-api" app' do
      expect(subject[:publishing_app]).to eq('hmrc-manuals-api')
    end

    it 'is a major update' do
      expect(subject[:update_type]).to eq('major')
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

  describe '#save!' do
    include GdsApi::TestHelpers::PublishingApi

    describe 'for an invalid manual' do
      subject(:removed_manual) { described_class.new('this_is_not_acc3ptABLE!') }

      it 'raises a validation error' do
        expect {
          subject.save!
        }.to raise_error(ValidationError)
      end

      it 'does not communicate with the publishing api' do
        publishing_api_stub = stub_default_publishing_api_put

        ignoring(ValidationError) { subject.save! }

        assert_not_requested publishing_api_stub
      end
    end

    describe 'for a valid manaul' do
      subject(:removed_manual) { described_class.new('some-slug') }
      let(:publishing_api_base_path) { '/hmrc-internal-manuals/some-slug' }

      it 'issues a put_item request to the publishing api to mark the manual as gone' do
        stub_default_publishing_api_put

        subject.save!

        assert_publishing_api_put_item(publishing_api_base_path, gone_manual_for_publishing_api)
      end
    end

    def ignoring(error_class, &block)
      block.call
    rescue error_class
    end
  end
end
