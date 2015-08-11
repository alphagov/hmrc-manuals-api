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

  subject(:publishing_api_manual) { PublishingAPIManual.new(slug, attributes, options) }
  let(:slug) { 'some-slug' }
  let(:options) { {} }

  describe '#to_h' do
    subject { publishing_api_manual.to_h }

    context 'valid_manual' do
      let(:attributes) { valid_manual }

      it { should be_valid_against_schema('hmrc_manual') }
    end

    context 'maximal_manual' do
      let(:attributes) { maximal_manual }

      it { should be_valid_against_schema('hmrc_manual') }
    end

    context 'linked_manual' do
      let(:attributes) { valid_manual }
      let(:options) {
        {
          manuals_topics_content_ids: {
            slug => [
              'aaaa1111-1111-1aaa-aaaa-111111111111',
              'bbbb2222-2222-2bbb-bbbb-222222222222',
            ]
          }
        }
      }

      it { should be_valid_against_schema('hmrc_manual') }
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
  end
end
