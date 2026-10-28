require "gds_api/test_helpers/asset_manager"

RSpec.shared_context "asset manager" do
  include ActiveSupport::Testing::TimeHelpers
  include GdsApi::TestHelpers::AssetManager

  let(:asset_id) { SecureRandom.hex }
  let(:additional_attributes) { {} }
  let(:asset_manager_response) do
    {
      _response_info: {
        status: "ok",
      },
      content_type: "text/plain",
      deleted: false,
      draft: false,
      file_url: "http://asset-manager.dev.gov.uk/media/#{asset_id}/asset.txt",
      id: "http://asset-manager/assets/#{asset_id}",
      name: "asset.txt",
      size: 12,
      state: "clean",
    }.merge(additional_attributes)
  end
  let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

  def decoded_token_payload_from_url(url)
    query_params = Rack::Utils.parse_query(URI(url).query)

    payload, _header = JWT.decode(
      query_params["token"],
      Rails.application.config.jwt_auth_secret,
      true,
      { algorithm: "HS256" },
    )

    payload
  end
end
