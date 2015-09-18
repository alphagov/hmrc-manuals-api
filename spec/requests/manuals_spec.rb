require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'
require 'gds_api/test_helpers/rummager'
require 'gds_api/test_helpers/content_register'

describe 'manuals resource' do
  include GdsApi::TestHelpers::PublishingApi
  include GdsApi::TestHelpers::Rummager
  include GdsApi::TestHelpers::ContentRegister

  it 'confirms update of the manual' do
    stub_default_publishing_api_put
    stub_any_rummager_post
    stub_content_register_entries('topic', maximal_manual_topics)

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')

    assert_publishing_api_put_item(maximal_manual_base_path, maximal_manual_for_publishing_api)
    assert_rummager_posted_item(maximal_manual_for_rummager)
    expect(response.headers['Location']).to include(maximal_manual_url)
    expect(response.body).to include(maximal_manual_url)
  end

  it 'handles Content Register being unavailable' do
    stub_default_publishing_api_put
    stub_any_rummager_post
    content_register_isnt_available

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(503)
  end

  it 'handles the Publishing API being unavailable' do
    publishing_api_isnt_available
    stub_any_rummager_post
    stub_content_register_entries('topic', maximal_manual_topics)

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(503)
  end

  it 'returns the status code from the Publishing API response, not Rummager' do
    stub_default_publishing_api_put  # This returns 200
    stub_any_rummager_post_with_queueing_enabled  # This returns 202, as it does in Production
    stub_content_register_entries('topic', maximal_manual_topics)

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(200)
  end

  it 'rejects invalid manual slugs' do
    put_json '/hmrc-manuals/BREAK_THE_RULEZ', valid_manual

    expect(response.status).to eq(422)
    expect(json_response['errors'].first).to eq("Slug should match the pattern: (?-mix:\\A[a-z\\d]+(?:-[a-z\\d]+)*\\z)")
  end

  it 'errors if the Accept header is not application/json' do
    stub_default_publishing_api_put
    stub_any_rummager_post
    stub_content_register_entries('topic', maximal_manual_topics)

    put "/hmrc-manuals/#{maximal_manual_slug}/", maximal_manual.to_json,
        headers = {'CONTENT_TYPE' => 'application/json',
                   'HTTP_ACCEPT'  => 'text/plain',
                   'HTTP_AUTHORIZATION' => 'Bearer 12345'}
    expect(response.status).to eq(406)
  end

  it 'errors if the Content-Type header is not application/json' do
    stub_default_publishing_api_put
    stub_any_rummager_post

    put "/hmrc-manuals/#{maximal_manual_slug}/", maximal_manual.to_json,
        headers = {'CONTENT_TYPE' => 'text/plain',
                   'HTTP_ACCEPT'  => 'application/json',
                   'HTTP_AUTHORIZATION' => 'Bearer 12345'}
    expect(response.status).to eq(415)
  end
end
