require 'rails_helper'

describe PublishingAPISection do
  describe 'base_path' do
    it 'returns the GOV.UK path for the section' do
      base_path = PublishingAPISection.base_path('some-manual', 'some-section-id')
      expect(base_path).to eql('/guidance/some-manual/some-section-id')
    end

    it 'ensures that it is lowercase' do
      base_path = PublishingAPISection.base_path('Some-Manual', 'Some-Section-id')
      expect(base_path).to eql('/guidance/some-manual/some-section-id')
    end
  end

  subject { PublishingAPISection.new("some-slug", "some-id", attributes) }

  context "with an empty payload" do
    let(:attributes) { {} }
    it { should_not be_valid }
  end

  context "with an invalid payload" do
    let(:attributes) { [] }
    it { should_not be_valid }
  end
end
