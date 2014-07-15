require 'rails_helper'

describe 'manuals resource' do
  it 'confirms update of the manual' do
    put_json '/hmrc-manuals/imaginary-slug', valid_manual

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
  end
end
