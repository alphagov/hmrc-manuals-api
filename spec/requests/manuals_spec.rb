require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'
require 'gds_api/test_helpers/rummager'

describe 'manuals resource' do
  include GdsApi::TestHelpers::PublishingApi
  include GdsApi::TestHelpers::Rummager

  it 'confirms update of the manual' do
    stub_default_publishing_api_put
    stub_any_rummager_post

    put_json '/hmrc-manuals/employment-income-manual', maximal_manual

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
    assert_publishing_api_put_item('/hmrc-internal-manuals/employment-income-manual', maximal_manual_for_publishing_api)
    assert_rummager_posted_item(maximal_manual_for_rummager)
    expect(response.headers['Location']).to include('https://www.gov.uk/hmrc-internal-manuals/employment-income-manual')
    expect(response.body).to include('https://www.gov.uk/hmrc-internal-manuals/employment-income-manual')
  end

  it 'handles the content store being unavailable' do
    publishing_api_isnt_available
    stub_any_rummager_post

    put_json '/hmrc-manuals/employment-income-manual', maximal_manual

    expect(response.status).to eq(503)
  end

  it 'rejects invalid manual slugs' do
    put_json '/hmrc-manuals/BREAK_THE_RULEZ', valid_manual

    expect(response.status).to eq(422)
    expect(json_response['errors'].first).to eq("Slug should match the pattern: (?-mix:\\A[a-z\\d]+(?:-[a-z\\d]+)*\\z)")
  end

  it 'errors if the Accept header is not application/json' do
    stub_default_publishing_api_put
    stub_any_rummager_post

    put '/hmrc-manuals/employment-income-manual/', maximal_manual.to_json,
        headers = {'CONTENT_TYPE' => 'application/json',
                   'HTTP_ACCEPT'  => 'text/plain',
                   'HTTP_AUTHORIZATION' => 'Bearer 12345'}
    expect(response.status).to eq(406)
  end

  it 'errors if the Content-Type header is not application/json' do
    stub_default_publishing_api_put
    stub_any_rummager_post

    put '/hmrc-manuals/employment-income-manual/', maximal_manual.to_json,
        headers = {'CONTENT_TYPE' => 'text/plain',
                   'HTTP_ACCEPT'  => 'application/json',
                   'HTTP_AUTHORIZATION' => 'Bearer 12345'}
    expect(response.status).to eq(415)
  end
end
