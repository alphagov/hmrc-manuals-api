require 'rails_helper'

describe PublishingAPISection do
  describe 'base_path' do
    it 'returns the GOV.UK path for the section' do
      base_path = PublishingAPISection.base_path('a-manual', 'a-section-id')
      expect(base_path).to eql('/guidance/a-manual/a-section-id')
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
