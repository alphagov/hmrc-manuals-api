require 'rails_helper'

describe PublishingAPISection do
  describe 'validations' do
    describe 'validating that section ID and slug match' do
      it 'rejects mismatches' do
        section = PublishingAPISection.new('manual', 'mismatch', valid_section)
        expect(section).to_not be_valid
        expect(section.errors[:base].first).to eql('Slug in URL and Section ID must match, ignoring case')
      end
    end
  end

  describe 'base_path' do
    it 'returns the GOV.UK path for the section' do
      base_path = PublishingAPISection.base_path('some-manual', 'some-section-id')
      expect(base_path).to eql('/hmrc-internal-manuals/some-manual/some-section-id')
    end

    it 'ensures that it is lowercase' do
      base_path = PublishingAPISection.base_path('Some-Manual', 'Some-Section-id')
      expect(base_path).to eql('/hmrc-internal-manuals/some-manual/some-section-id')
    end
  end

  subject { PublishingAPISection.new("some-slug", "some-id", attributes) }

  describe 'to_h' do
    context 'valid_section' do
      let(:attributes) { valid_section }

      it 'should be valid against the govuk-content-schema' do
        expect(subject.to_h).to be_valid_against_schema('hmrc_manual_section')
      end
    end

    context 'maximal_section' do
      let(:attributes) { maximal_section }

      it 'should be valid against the govuk-content-schema' do
        expect(subject.to_h).to be_valid_against_schema('hmrc_manual_section')
      end
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
