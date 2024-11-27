require "rails_helper"
require "gds_api/test_helpers/publishing_api"

describe "manuals resource" do
  include GdsApi::TestHelpers::PublishingApi
  include LinksUpdateHelper
  include PublishingApiHelper

  it "confirms update of the manual" do
    stub_any_publishing_api_call
    stub_any_publishing_api_put_content.to_return(body: { version: nil }.to_json)
    stub_publishing_api_get_links(maximal_manual_content_id)
    stub_put_default_organisation(maximal_manual_content_id)
    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(200)
    expect(response.headers["Content-Type"]).to include("application/json")

    assert_publishing_api_put_content(maximal_manual_content_id, maximal_manual_for_publishing_api)
    assert_publishing_api_publish(maximal_manual_content_id, update_type: nil)
    expect(response.headers["Location"]).to include(maximal_manual_url)
    expect(response.body).to include(maximal_manual_url)
  end

  it "handles the Publishing API being unavailable" do
    stub_publishing_api_isnt_available

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(503)
  end

  it "handles Publishing API put_content returning 409" do
    stub_publishing_api_put_content(maximal_manual_content_id, {}, status: 409)

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(500)
  end

  it "handles the Publishing API returning an unproccessable entity error" do
    publishing_api_validation_error

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(422)
  end

  it "returns the status code from the Publishing API response" do
    stub_any_publishing_api_call
    stub_any_publishing_api_put_content.to_return(body: { version: nil }.to_json)
    stub_publishing_api_get_links(maximal_manual_content_id)
    stub_put_default_organisation(maximal_manual_content_id)

    put_json "/hmrc-manuals/#{maximal_manual_slug}", maximal_manual

    expect(response.status).to eq(200)
  end

  it "rejects invalid manual slugs" do
    put_json "/hmrc-manuals/BREAK_THE_RULEZ", valid_manual

    expect(response.status).to eq(422)
    expect(json_response["errors"].first).to eq("Slug should match the pattern: (?-mix:\\A[a-z\\d]+(?:-[a-z\\d]+)*\\z)")
  end

  it "errors if the Accept header is not application/json" do
    stub_any_publishing_api_call
    stub_any_publishing_api_put_content.to_return(body: { version: nil }.to_json)
    stub_publishing_api_get_links(maximal_manual_content_id)
    stub_put_default_organisation(maximal_manual_content_id)

    put "/hmrc-manuals/#{maximal_manual_slug}/",
        params: maximal_manual.to_json,
        headers: { "CONTENT_TYPE" => "application/json",
                   "HTTP_ACCEPT" => "text/plain",
                   "HTTP_AUTHORIZATION" => "Bearer 12345" }
    expect(response.status).to eq(406)
  end

  it "errors if the Content-Type header is not application/json" do
    stub_any_publishing_api_call

    put "/hmrc-manuals/#{maximal_manual_slug}/",
        params: maximal_manual.to_json,
        headers: { "CONTENT_TYPE" => "text/plain",
                   "HTTP_ACCEPT" => "application/json",
                   "HTTP_AUTHORIZATION" => "Bearer 12345" }
    expect(response.status).to eq(415)
  end
end
