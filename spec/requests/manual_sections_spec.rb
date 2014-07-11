require 'rails_helper'

describe 'manual sections resource' do
  let(:valid_section) { { title: 'Section 12345' } }

  it 'confirms update of the manual section' do
    put_json '/hmrc-manuals/imaginary-slug/sections/EIM12345', valid_section

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
  end
end
