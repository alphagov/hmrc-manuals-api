require 'rails_helper'

describe ContentStoreManual do
  describe 'base_path' do
    it 'returns the GOV.UK path for the manual' do
      base_path = ContentStoreManual.base_path('a-manual')
      expect(base_path).to eql('/guidance/a-manual')
    end
  end
end
