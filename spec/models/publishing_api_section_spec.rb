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

  subject(:publishing_api_section) {
    PublishingAPISection.new(manual_slug, section_slug, attributes, options)
  }
  let(:manual_slug) { 'some-slug' }
  let(:section_slug) { 'some_id' } 
  let(:options) { { known_manual_slugs: known_manual_slugs } }
  let(:known_manual_slugs) { [] }

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

    context 'when app is configured to only allow known manual slugs' do
      let(:attributes) { valid_section }
      #section_slug and section_id have to match to pass `:section_slug_matches_section_id` validation
      let(:section_slug) { valid_section['details']['section_id'] }
      let(:known_manual_slugs) { ['known-manual-slug'] }

      before do
        allow(HMRCManualsAPI::Application.config).to receive(:allow_unknown_hmrc_manual_slugs).and_return(false)
      end

      context "with a manual slug name not in list of known slugs" do
        let(:manual_slug) { 'non-existent-slug' }
        it { should_not be_valid }
      end

      context "with a manual slug name in list of known slugs" do
        let(:manual_slug) { 'known-manual-slug' }
        it { should be_valid }
      end
    end
  end
end
