require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'
require 'gds_api/test_helpers/rummager'
require 'gds_api/test_helpers/content_store'

describe PublishingAPIRedirectedSection do
  describe 'validations' do
    context 'on section_slug' do
      it 'is invalid when it is missing' do
        expect(described_class.new('manual-slug', nil, 'manual-redirect-slug', 'section-redirect-slug')).not_to be_valid
      end

      it 'is invalid when it does not match the valid_slug/pattern' do
        expect(described_class.new('manual-sug', "1Som\nSłu9G!", 'manual-redirect-slug', 'section-redirect-slug')).not_to be_valid
      end
    end

    context 'on manual_slug' do
      it 'is invalid when it is missing' do
        expect(described_class.new(nil, 'section-slug', 'manual-redirect-slug', 'section-redirect-slug')).not_to be_valid
      end

      it 'is invalid when it does not match the valid_slug/pattern' do
        expect(described_class.new("1Som\nSłu9G!", 'section-slug', 'manual-redirect-slug', 'section-redirect-slug')).not_to be_valid
      end
    end

    context 'on destination_section_slug' do
      it 'is invalid when it is missing' do
        expect(described_class.new('manual-slug', 'section-slug', 'manual-redirect-slug', nil)).not_to be_valid
      end

      it 'is invalid when it does not match the valid_slug/pattern' do
        expect(described_class.new('manual-sug', 'section-slug', 'manual-redirect-slug', "1Som\nSłu9G!")).not_to be_valid
      end
    end

    context 'on destination_manual_slug' do
      it 'is invalid when it is missing' do
        expect(described_class.new('manual-slug', 'section-slug', nil, 'section-redirect-slug')).not_to be_valid
      end

      it 'is invalid when it does not match the valid_slug/pattern' do
        expect(described_class.new('manual-slug', 'section-slug', "1Som\nSłu9G!", 'section-redirect-slug-slug')).not_to be_valid
      end
    end
    
    context 'checking that the manual section exists already' do
      include GdsApi::TestHelpers::ContentStore

      let(:manual_slug) { 'manual' }
      let(:section_slug) { 'section' }
      let(:manual_redirect_slug) { 'redirect-manual' }
      let(:section_redirect_slug) { 'redirect-section' }
      let(:section_path) { subject.base_path }
      subject(:removed_manual) { described_class.new(manual_slug, section_slug, manual_redirect_slug, section_redirect_slug) }

      it 'is invalid if the slugs do not represent a piece of content' do
        content_store_does_not_have_item(section_path)
        expect(subject).not_to be_valid
      end

      it 'is invalid if the slugs already represent a "gone" piece of content' do
        content_item = content_item_for_base_path(section_path).merge("format" => "gone")
        content_store_has_item(section_path, content_item)
        expect(subject).not_to be_valid
      end

      it 'is valid when the slugs represent an "hmrc-manual-section" piece of content' do
        content_item = hmrc_manual_section_content_item_for_base_path(section_path)
        content_store_has_item(section_path, content_item)
        expect(subject).to be_valid
      end

      it 'is invalid when the slugs represent any other format piece of content' do
        content_store_has_item(section_path)
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#to_h' do
    let(:redirected_manual_section) { described_class.new('some-manual', 'some-section', 'manual-redirect', 'section-redirect') }
    subject(:redirected_manual_section_as_hash) { redirected_manual_section.to_h }

    context 'valid schema' do
      it { should be_valid_against_schema('redirect') }
    end

    it 'is a "redirect" format object' do
      expect(subject[:format]).to eq('redirect')
    end

    it 'is published by the "hmrc-manuals-api" app' do
      expect(subject[:publishing_app]).to eq('hmrc-manuals-api')
    end
  end

  describe '#save!' do
    include GdsApi::TestHelpers::PublishingApiV2
    include GdsApi::TestHelpers::Rummager
    include GdsApi::TestHelpers::ContentStore
    before do
      content_item = hmrc_manual_section_content_item_for_base_path(subject.base_path)
      content_store_has_item(subject.base_path, content_item)
    end

    describe 'for an invalid manual section' do
      subject(:removed_manual_section) { described_class.new('this_is_not_acc3ptABLE!', 'is it?', 'redirect_manual_slug', 'redirect_section_slug') }

      it 'raises a validation error' do
        expect { subject.save! }.to raise_error(ValidationError)
      end

      it 'does not communicate with the publishing api' do
        publishing_api_stub = stub_any_publishing_api_put_content

        ignoring_error(ValidationError) { subject.save! }

        assert_not_requested publishing_api_stub
      end
    end

    describe 'for a valid manual section' do
      subject(:redirected_manual_section) { described_class.new('some-manual', 'some-section', 'some-other-manual', 'some-other-section') }

      it 'issues put_content and publish requests to the publishing api to mark the manual section as gone' do
        stub_publishing_api_put_content(redirected_manual_section.content_id, {}, { body: {version: 33} })
        stub_publishing_api_publish(redirected_manual_section.content_id, { update_type: 'major', previous_version: 33}.to_json)

        subject.save!

        assert_publishing_api_put_content(redirected_manual_section.content_id, redirected_manual_section_for_publishing_api)
        assert_publishing_api_publish(redirected_manual_section.content_id, {update_type: redirected_manual_section.update_type})
      end
    end
  end

  def hmrc_manual_section_content_item_for_base_path(base_path)
    content_item_for_base_path(base_path).merge("format" => SECTION_FORMAT)
  end
end
