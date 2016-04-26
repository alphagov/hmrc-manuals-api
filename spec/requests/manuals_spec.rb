require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'
require 'gds_api/test_helpers/rummager'

describe 'manuals resource' do
  include GdsApi::TestHelpers::PublishingApiV2
  include GdsApi::TestHelpers::Rummager
  include LinksUpdateHelper

  it 'confirms update of the manual' do
    allow_any_instance_of(GdsApi::Response).to receive(:version)
    stub_any_publishing_api_call
    stub_any_rummager_post
    stub_publishing_api_get_links(maximal_manual_content_id)
    stub_put_default_organisation(maximal_manual_content_id)

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
    assert_publishing_api_put_content(maximal_manual_content_id, maximal_manual_for_publishing_api)
    assert_publishing_api_publish(maximal_manual_content_id, {update_type: 'major'})
    assert_rummager_posted_item(maximal_manual_for_rummager)
    expect(response.headers['Location']).to include(maximal_manual_url)
    expect(response.body).to include(maximal_manual_url)
  end

  it 'handles the Publishing API being unavailable' do
    publishing_api_isnt_available
    stub_any_rummager_post

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(503)
  end

  it 'handles Publishing API put_content returning 409' do
    stub_publishing_api_put_content(maximal_manual_content_id, {}, {status: 409})
    stub_any_rummager_post

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(500)
  end

  it 'returns the status code from the Publishing API response, not Rummager' do
    allow_any_instance_of(GdsApi::Response).to receive(:version)
    stub_any_publishing_api_call
    stub_any_rummager_post_with_queueing_enabled # This returns 202, as it does in Production
    stub_publishing_api_get_links(maximal_manual_content_id)
    stub_put_default_organisation(maximal_manual_content_id)

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(200)
  end

  it 'rejects invalid manual slugs' do
    put_json '/hmrc-manuals/BREAK_THE_RULEZ', valid_manual

    expect(response.status).to eq(422)
    expect(json_response['errors'].first).to eq("Slug should match the pattern: (?-mix:\\A[a-z\\d]+(?:-[a-z\\d]+)*\\z)")
  end

  it 'errors if the Accept header is not application/json' do
    allow_any_instance_of(GdsApi::Response).to receive(:version)
    stub_any_publishing_api_call
    stub_any_rummager_post
    stub_publishing_api_get_links(maximal_manual_content_id)
    stub_put_default_organisation(maximal_manual_content_id)

    put "/hmrc-manuals/#{maximal_manual_slug}/", maximal_manual.to_json, {
      'CONTENT_TYPE' => 'application/json',
      'HTTP_ACCEPT' => 'text/plain',
      'HTTP_AUTHORIZATION' => 'Bearer 12345'
    }
    expect(response.status).to eq(406)
  end

  it 'errors if the Content-Type header is not application/json' do
    stub_any_publishing_api_call
    stub_any_rummager_post

    put "/hmrc-manuals/#{maximal_manual_slug}/", maximal_manual.to_json, {
      'CONTENT_TYPE' => 'text/plain',
      'HTTP_ACCEPT'  => 'application/json',
      'HTTP_AUTHORIZATION' => 'Bearer 12345'
    }
    expect(response.status).to eq(415)
  end
end
