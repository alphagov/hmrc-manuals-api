require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

describe 'manuals resource' do
  include GdsApi::TestHelpers::PublishingApi

  it 'confirms update of the manual' do
    stub_default_publishing_api_put

    put_json '/hmrc-manuals/employment-income-manual', maximal_manual

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
    assert_publishing_api_put_item('/guidance/employment-income-manual', maximal_manual_for_publishing_api)
    expect(response.headers['Location']).to include('https://www.gov.uk/guidance/employment-income-manual')
    expect(response.body).to include('https://www.gov.uk/guidance/employment-income-manual')
  end

  it 'handles the content store being unavailable' do
    publishing_api_isnt_available

    put_json '/hmrc-manuals/employment-income-manual', maximal_manual

    expect(response.status).to eq(503)
  end

  it 'rejects invalid manual slugs' do
    put_json '/hmrc-manuals/BREAK_THE_RULEZ', valid_manual

    expect(response.status).to eq(422)
    expect(json_response['errors'].first).to eq("Slug should match the pattern: (?-mix:\\A[a-z\\d][a-z\\d-]*[a-z\\d]\\z)")
  end
  
  it 'errors if the Accept header and/or the Content-Type header is/are not application/json' do
    stub_default_publishing_api_put

    put_json_with_invalid_headers '/hmrc-manuals/employment-income-manual/', maximal_manual

    expect(response.status).to eq(415)
  end
end
