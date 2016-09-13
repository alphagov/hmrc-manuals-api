require 'rails_helper'

describe 'authentication' do
  it 'reject the request if no bearer token is present' do
    put_json '/hmrc-manuals/imaginary-slug', valid_manual, "HTTP_AUTHORIZATION" => ""

    expect(response.status).to eq(401)
  end
end
