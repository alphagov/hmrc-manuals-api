require 'rails_helper'

describe 'manual sections resource' do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:data) { { foo: 'bar' }.to_json }

  it 'confirms update of the manual section' do
    put '/hmrc-manuals/imaginary-slug/sections/EIM12345', data, headers

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
  end
end
