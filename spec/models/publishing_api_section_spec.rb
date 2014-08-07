require 'rails_helper'

describe PublishingAPISection do
  describe 'base_path' do
    it 'returns the GOV.UK path for the section' do
      base_path = PublishingAPISection.base_path('a-manual', 'a-section-id')
      expect(base_path).to eql('/guidance/a-manual/a-section-id')
    end
  end
end
