require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'
require 'gds_api/test_helpers/rummager'

describe 'manual sections resource' do
  include GdsApi::TestHelpers::PublishingApiV2
  include GdsApi::TestHelpers::Rummager
  include LinksUpdateHelper

  let(:maximal_section_endpoint) {
    "/hmrc-manuals/#{maximal_manual_slug}/sections/#{maximal_section_slug}"
  }

  it 'confirms update of the manual section' do
    stub_publishing_api_put_content(maximal_section_content_id, {}, { body: {version: 788} })
    stub_publishing_api_publish(maximal_section_content_id, { update_type: 'minor', previous_version: 788}.to_json)
    stub_any_rummager_post
    stub_publishing_api_get_links(maximal_section_content_id)
    stub_put_default_organisation(maximal_section_content_id)

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
    assert_publishing_api_put_content(maximal_section_content_id, maximal_section_for_publishing_api)
    assert_rummager_posted_item(maximal_section_for_rummager)
    expect(response.headers['Location']).to include(maximal_section_url)
    expect(response.body).to include(maximal_section_url)
  end

  it 'errors if the Accept header is not application/json' do
    stub_publishing_api_put_content(maximal_section_content_id, {}, { body: {version: 12} })
    stub_publishing_api_publish(maximal_section_content_id, { update_type: 'minor', previous_version: 12}.to_json)
    stub_any_rummager_post
    stub_publishing_api_get_links(maximal_section_content_id)
    stub_put_default_organisation(maximal_section_content_id)

    put maximal_section_endpoint, maximal_section.to_json, {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_ACCEPT'  => 'text/plain',
      'HTTP_AUTHORIZATION' => 'Bearer 12345'
    }
    expect(response.status).to eq(406)
  end

  it 'errors if the Content-Type header is not application/json' do
    stub_any_publishing_api_call

    put maximal_section_endpoint, maximal_section.to_json, {
      'CONTENT_TYPE' => 'text/plain',
      'HTTP_ACCEPT'  => 'application/json',
      'HTTP_AUTHORIZATION' => 'Bearer 12345'
    }
    expect(response.status).to eq(415)
  end

  it 'handles the Publishing API being unavailable' do
    publishing_api_isnt_available

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(503)
  end

  it 'handles the Publishing API request timing out' do
    publishing_api_times_out

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(503)
  end

  it 'handles some other error with the Publishing API' do
    publishing_api_validation_error

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(500)
  end

  it 'returns the status code from the Publishing API response, not Rummager' do
    stub_publishing_api_put_content(maximal_section_content_id, {}, { body: { version: 788 } }) # This returns 200
    stub_publishing_api_publish(maximal_section_content_id, { update_type: 'minor', previous_version: 788}.to_json)
    stub_any_rummager_post # This returns 202, as it does in Production
    stub_publishing_api_get_links(maximal_section_content_id)
    stub_put_default_organisation(maximal_section_content_id)

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(200)
  end

  it 'rejects invalid manual slugs' do
    put_json '/hmrc-manuals/BREAK_THE_RULEZ/sections/some-section', valid_section

    expect(response.status).to eq(422)
    expect(json_response['errors'].first).to eq("Manual slug should match the pattern: (?-mix:\\A[a-z\\d]+(?:-[a-z\\d]+)*\\z)")
  end

  it 'rejects invalid section slugs' do
    put_json '/hmrc-manuals/some-manual/sections/BREAK_THE_RULEZ', valid_section

    expect(response.status).to eq(422)
    expect(json_response['errors'].first).to eq("Section slug should match the pattern: (?-mix:\\A[a-z\\d]+(?:-[a-z\\d]+)*\\z)")
  end

private
  def publishing_api_times_out
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT}\/.*/).to_timeout
  end

  def publishing_api_validation_error
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT}\/.*/).to_return(status: 422)
  end
end
