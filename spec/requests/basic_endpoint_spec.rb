require 'rails_helper'

describe 'PUT to hmrc-manuals path' do
  before do
    data = { foo: 'bar' }
    headers = { 'Content-Type' => 'application/json' }
    put '/hmrc-manuals/imaginary-slug', data.to_json, headers
  end

  it 'responds with a 200 status code' do
    expect(response).to be_success
  end

  it 'sets an application/json Content-Type header' do
    expect(response.headers['Content-Type']).to eq('application/json')
  end

  it 'returns JSON' do
    expect(JSON.parse(response.body)).to eq({ 'status' => 'ok' })
  end
end
