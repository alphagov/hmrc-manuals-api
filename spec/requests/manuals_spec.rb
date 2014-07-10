require 'rails_helper'

describe 'manuals resource' do
  let(:data) { { foo: 'bar' } }

  it 'confirms update of the manual' do
    put_json '/hmrc-manuals/imaginary-slug', data

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
  end
end
