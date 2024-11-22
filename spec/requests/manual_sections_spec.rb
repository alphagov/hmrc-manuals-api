require "rails_helper"
require "gds_api/test_helpers/publishing_api"

describe "manual sections resource" do
  include GdsApi::TestHelpers::PublishingApi
  include LinksUpdateHelper
  include PublishingApiHelper

  let(:maximal_section_endpoint) do
    "/hmrc-manuals/#{maximal_manual_slug}/sections/#{maximal_section_slug}"
  end

  it "confirms update of the manual section" do
    stub_publishing_api_put_content(maximal_section_content_id, {}, body: { version: 788 })
    stub_publishing_api_publish(maximal_section_content_id, { update_type: nil, previous_version: 788 }.to_json)
    stub_publishing_api_get_links(maximal_section_content_id)
    stub_put_default_organisation(maximal_section_content_id)

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(200)
    expect(response.headers["Content-Type"]).to include("application/json")
    assert_publishing_api_put_content(maximal_section_content_id, maximal_section_for_publishing_api)
    expect(response.headers["Location"]).to include(maximal_section_url)
    expect(response.body).to include(maximal_section_url)
  end

  it "errors if the Accept header is not application/json" do
    stub_publishing_api_put_content(maximal_section_content_id, {}, body: { version: 12 })
    stub_publishing_api_publish(maximal_section_content_id, { update_type: nil, previous_version: 12 }.to_json)
    stub_publishing_api_get_links(maximal_section_content_id)
    stub_put_default_organisation(maximal_section_content_id)

    put maximal_section_endpoint,
        params: maximal_section.to_json,
        headers: { "CONTENT_TYPE" => "application/json",
                   "HTTP_ACCEPT" => "text/plain",
                   "HTTP_AUTHORIZATION" => "Bearer 12345" }
    expect(response.status).to eq(406)
  end

  it "errors if the Content-Type header is not application/json" do
    stub_any_publishing_api_call

    put maximal_section_endpoint,
        params: maximal_section.to_json,
        headers: { "CONTENT_TYPE" => "text/plain",
                   "HTTP_ACCEPT" => "application/json",
                   "HTTP_AUTHORIZATION" => "Bearer 12345" }
    expect(response.status).to eq(415)
  end

  it "handles the Publishing API being unavailable" do
    stub_publishing_api_isnt_available

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(503)
  end

  it "handles the Publishing API request timing out" do
    publishing_api_times_out

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(503)
  end

  it "handles the Publishing API returning an unproccessable entity error" do
    publishing_api_validation_error

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(422)
  end

  it "returns the status code from the Publishing API response" do
    stub_publishing_api_put_content(maximal_section_content_id, {}, body: { version: 788 }) # This returns 200
    stub_publishing_api_publish(maximal_section_content_id, { update_type: nil, previous_version: 788 }.to_json)
    stub_publishing_api_get_links(maximal_section_content_id)
    stub_put_default_organisation(maximal_section_content_id)

    put_json maximal_section_endpoint, maximal_section

    expect(response.status).to eq(200)
  end

  it "rejects invalid manual slugs" do
    put_json "/hmrc-manuals/BREAK_THE_RULEZ/sections/some-section", valid_section

    expect(response.status).to eq(422)
    expect(json_response["errors"].first).to eq("Manual slug should match the pattern: (?-mix:\\A[a-z\\d]+(?:-[a-z\\d]+)*\\z)")
  end

  it "rejects invalid section slugs" do
    put_json "/hmrc-manuals/some-manual/sections/BREAK_THE_RULEZ", valid_section

    expect(response.status).to eq(422)
    expect(json_response["errors"].first).to eq("Section slug should match the pattern: (?-mix:\\A[a-z\\d]+(?:-[a-z\\d]+)*\\z)")
  end

private

  def publishing_api_times_out
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}\/.*/).to_timeout
  end
end
