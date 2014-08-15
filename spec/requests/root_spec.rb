require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

describe 'root resource' do
  describe '/' do
    it 'should not error' do
      get '/'
      expect(response.status).to eql(200)
    end
  end

  describe '/readme' do
    it 'should not error' do
      get '/readme'
      expect(response.status).to eql(200)
    end
  end
end
