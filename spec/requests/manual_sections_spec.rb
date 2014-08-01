require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

describe 'manual sections resource' do
  include GdsApi::TestHelpers::PublishingApi

  it 'confirms update of the manual section' do
    stub_default_publishing_api_put

    put_json '/hmrc-manuals/employment-income-manual/sections/12345', maximal_section

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
    assert_publishing_api_put_item('/guidance/employment-income-manual/12345', maximal_section_for_publishing_api)
  end

  it 'handles the content store being unavailable' do
    publishing_api_isnt_available

    put_json '/hmrc-manuals/employment-income-manual/sections/12345', maximal_section

    expect(response.status).to eq(503)
  end

  it 'handles the content store request timing out' do
    publishing_api_times_out

    put_json '/hmrc-manuals/employment-income-manual/sections/12345', maximal_section

    expect(response.status).to eq(503)
  end

  it 'handles some other error with the content store' do
    publishing_api_validation_error

    put_json '/hmrc-manuals/employment-income-manual/sections/12345', maximal_section

    expect(response.status).to eq(500)
  end

private
  def publishing_api_times_out
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT}\/.*/).to_timeout
  end

  def publishing_api_validation_error
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT}\/.*/).to_return(:status => 422)
  end
end
