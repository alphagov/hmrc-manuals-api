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
    expect(response.headers['Location']).to include("https://www.gov.uk/guidance/employment-income-manual/12345")
    expect(response.body).to include("https://www.gov.uk/guidance/employment-income-manual/12345")
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

  it 'rejects invalid manual slugs' do
    put_json '/hmrc-manuals/BREAK_THE_RULEZ/sections/a-section', valid_section

    expect(response.status).to eq(422)
    expect(json_response['errors'].first).to eq("Manual slug should match the pattern: (?-mix:\\A[a-z\\d][a-z\\d-]*[a-z\\d]\\z)")
  end

  it 'rejects invalid section slugs' do
    put_json '/hmrc-manuals/a-manual/sections/BREAK_THE_RULEZ', valid_section

    expect(response.status).to eq(422)
    expect(json_response['errors'].first).to eq("Section slug should match the pattern: (?-mix:\\A[a-z\\d][a-z\\d-]*[a-z\\d]\\z)")
  end

private
  def publishing_api_times_out
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT}\/.*/).to_timeout
  end

  def publishing_api_validation_error
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT}\/.*/).to_return(:status => 422)
  end
end
