require 'rails_helper'

describe PublishingAPISection do
  describe '.base_path' do
    it 'returns the GOV.UK path for the section' do
      base_path = PublishingAPISection.base_path('some-manual', 'some-section-id')
      expect(base_path).to eql('/hmrc-internal-manuals/some-manual/some-section-id')
    end

    it 'ensures that it is lowercase' do
      base_path = PublishingAPISection.base_path('Some-Manual', 'Some-Section-id')
      expect(base_path).to eql('/hmrc-internal-manuals/some-manual/some-section-id')
    end
  end

  subject(:publishing_api_section) { PublishingAPISection.new("some-slug", "some-id", attributes) }

  describe '#to_h' do
    let(:subject) { publishing_api_section.to_h }

    context 'valid_section' do
      let(:attributes) { valid_section }

      it { should be_valid_against_schema('hmrc_manual_section') }
    end

    context 'maximal_section' do
      let(:attributes) { maximal_section }

      it { should be_valid_against_schema('hmrc_manual_section') }
    end
  end

  describe 'validations' do
    context 'mismatched section ID and slug' do
      subject { PublishingAPISection.new('manual', 'mismatch', valid_section) }

      it { should_not be_valid}

      it 'rejects mismatches' do
        subject.valid? # trigger validations and populate errors
        expect(subject.errors[:base].first).to eql('Slug in URL and Section ID must match, ignoring case')
      end
    end

    context "with an empty payload" do
      let(:attributes) { {} }
      it { should_not be_valid }
    end

    context "with an invalid payload" do
      let(:attributes) { [] }
      it { should_not be_valid }
    end
  end
end
