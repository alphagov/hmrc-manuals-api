require 'rails_helper'

describe PublishingAPIManual do
  describe '.base_path' do
    it 'returns the GOV.UK path for the manual' do
      base_path = PublishingAPIManual.base_path('some-manual')
      expect(base_path).to eql('/hmrc-internal-manuals/some-manual')
    end

    it 'ensures that it is lowercase' do
      base_path = PublishingAPIManual.base_path('Some-Manual')
      expect(base_path).to eql('/hmrc-internal-manuals/some-manual')
    end
  end

  describe '.extract_slug_from_path' do
    it 'finds the first path segment after the base path segment' do
      extracted_slug = described_class.extract_slug_from_path('/hmrc-internal-manuals/what-a-slug')
      expect(extracted_slug).to eq('what-a-slug')
    end

    it 'ignores trailing slashes' do
      extracted_slug = described_class.extract_slug_from_path('/hmrc-internal-manuals/what-a-slug/')
      expect(extracted_slug).to eq('what-a-slug')
    end

    it 'ignores path segments after the first one' do
      extracted_slug = described_class.extract_slug_from_path('/hmrc-internal-manuals/what-a-slug/section-slug')
      expect(extracted_slug).to eq('what-a-slug')
    end

    it 'raises an InvalidPathErrorInvalidPathError exception if the path is blank' do
      expect {
        described_class.extract_slug_from_path('')
      }.to raise_error(InvalidPathError)
    end

    it 'raises an InvalidPathError exception if the path does not start with the base path segment' do
      expect {
        described_class.extract_slug_from_path('/fco-travel-advice/dont-go-back-to-rockville')
      }.to raise_error(InvalidPathError)
    end

    it 'raises an InvalidPathError exception if the path does start with the base path segment, but has no 2nd path segment' do
      expect {
        described_class.extract_slug_from_path('/hmrc-internal-manuals/')
      }.to raise_error(InvalidPathError)
    end
  end

  subject(:publishing_api_manual) {
    PublishingAPIManual.new(slug, attributes, options)
  }
  let(:slug) { 'some-slug' }
  let(:attributes) { valid_manual }
  let(:options) { { topics: topics, known_manual_slugs: known_manual_slugs } }
  let(:topics) { double(content_ids: [], slugs: []) }
  let(:known_manual_slugs) { [] }

  describe '#to_h' do
    subject { publishing_api_manual.to_h }

    context 'valid_manual' do
      it { should be_valid_against_schema('hmrc_manual') }
    end

    context 'maximal_manual' do
      let(:attributes) { maximal_manual }

      it { should be_valid_against_schema('hmrc_manual') }
    end

    context 'linked_manual' do
      let(:topics) {
        double(
          content_ids: [
            'aaaa1111-1111-1aaa-aaaa-111111111111',
            'bbbb2222-2222-2bbb-bbbb-222222222222',
          ],
          slugs: [
            'a-topic/sub-topic',
            'another-topic/sub-topic',
          ],
        )
      }

      it { should be_valid_against_schema('hmrc_manual') }
    end

    context "when no content_id is present" do
      it "should be generated from base_path" do
        expect(publishing_api_manual.manual.manual_attributes["content_id"]).to be_nil

        uuid = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, publishing_api_manual.base_path).to_s
        expect(publishing_api_manual.to_h["content_id"]).to eq(uuid)
      end
    end

    context "when content_id is present" do
      let(:content_id) { SecureRandom.uuid }
      let(:attributes) { valid_manual.merge("content_id" => content_id) }

      it "should be preserved" do
        expect(publishing_api_manual.to_h["content_id"]).to eq(content_id)
      end
    end
  end

  describe 'validations' do
    context "with an empty payload" do
      let(:attributes) { {} }
      it { should_not be_valid }
    end

    context "with an invalid payload" do
      let(:attributes) { [] }
      it { should_not be_valid }
    end

    context "with an invalid title" do
      let(:attributes) { valid_manual(title: "title <script></script>") }

      it "is invalid" do
        expect(subject).to_not be_valid
        expect(subject).to have(1).error_on(:base)
        expect(subject.errors.full_messages[0]).to match(%r{'#/title' contains disallowed HTML})
      end
    end

    context "with invalid child section groups" do
      let(:child_section_group_with_dangerous_title) { { "title" => "title <script></script>", "child_sections" => [] } }
      let(:attributes) { valid_manual("details" => { "child_section_groups" => [ child_section_group_with_dangerous_title ] * 2 }) }

      it "is invalid" do
        expect(subject).to_not be_valid
        expect(subject).to have(2).errors_on(:base)
        expect(subject.errors.full_messages[0]).to match(
          %r{'#/details/child_section_groups\[0\]/title' contains disallowed HTML})
        expect(subject.errors.full_messages[1]).to match(
          %r{'#/details/child_section_groups\[1\]/title' contains disallowed HTML})
      end
    end

    context 'when app is configured to only allow known slugs' do
      before do
        allow(HMRCManualsAPI::Application.config).to receive(:allow_unknown_hmrc_manual_slugs).and_return(false)
      end

      let(:known_manual_slugs) { ['known-manual-slug'] }

      context "with a manual slug name not in list of known slugs" do
        let(:slug) { 'non-existent-slug' }
        it { should_not be_valid }
      end

      context "with a manual slug name in list of known slugs" do
        let(:slug) { 'known-manual-slug' }
        it { should be_valid }
      end
    end

    context 'when app is configured to allow unknown slugs' do
      before do
        allow(HMRCManualsAPI::Application.config).to receive(:allow_unknown_hmrc_manual_slugs).and_return(true)
      end

      let(:known_manual_slugs) { ['known-manual-slug'] }

      context "with a manual slug name not in list of known slugs" do
        let(:slug) { 'non-existent-slug' }
        it { should be_valid }
      end

      context "with a manual slug name in list of known slugs" do
        let(:slug) { 'known-manual-slug' }
        it { should be_valid }
      end
    end
  end
end
