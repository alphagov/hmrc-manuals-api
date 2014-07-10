require 'rails_helper'

describe 'manuals resource' do
  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:data) { { foo: 'bar' }.to_json }

  it 'confirms update of the manual' do
    put '/hmrc-manuals/imaginary-slug', data, headers

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
  end
end
