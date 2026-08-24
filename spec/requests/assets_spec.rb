require "rails_helper"
require "gds_api/test_helpers/asset_manager"

describe "assets resource" do
  include ActiveSupport::Testing::TimeHelpers
  include GdsApi::TestHelpers::AssetManager

  let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

  context "when the allow_asset_manager_requests feature flag is false" do
    subject do
      get "/assets/123456789"
    end

    before do
      allow(Rails.application.config).to receive(:allow_asset_manager_requests).and_return(false)

      subject
    end

    it "responds with 501 Not Implemented" do
      expect(response).to have_http_status(:not_implemented)
    end

    it "makes no requests to Asset Manager" do
      expect(stub_any_asset_manager_call).not_to have_been_requested
    end
  end

  describe "GET /assets/:id" do
    let(:asset_id) { SecureRandom.hex }
    let(:asset_manager_response) do
      {
        _response_info: {
          status: "ok",
        },
        content_type: "text",
        deleted: "false",
        draft: "false",
        file_url: "http://asset-manager.dev.gov.uk/media/#{asset_id}/asset.txt",
        id: "http://asset-manager/assets/#{asset_id}",
        name: "asset.txt",
        size: "12",
        state: "clean",
      }
    end
    let(:stub_asset_manager_request) { stub_asset_manager_request_to_get_asset(asset_id, asset_manager_response.deep_stringify_keys) }

    subject do
      get "/assets/#{asset_id}"
    end

    before do
      stub_asset_manager_request
      subject
    end

    context "when Asset Manager responds with ok" do
      it "responds with 200 OK" do
        expect(response).to have_http_status(:ok)
      end

      it "makes a request to Asset Manager" do
        expect(stub_asset_manager_request).to have_been_requested.once
      end

      it "responds with data from Asset Manager" do
        expect(parsed_response).to include(asset_manager_response)
        expect(parsed_response).to include(asset_id:)
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPNotFound" do
      let(:stub_asset_manager_request) { stub_asset_manager_does_not_have_an_asset(asset_id) }

      it "responds with 404 Not Found" do
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("Asset not found")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_request) { stub_asset_manager_get_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("Access to asset is forbidden")
      end
    end
  end

  describe "POST /assets" do
    let(:draft) { true }
    let(:asset_manager_response) do
      {
        _response_info: {
          status: "ok",
        },
        content_type: "text",
        deleted: "false",
        draft: draft.to_s,
        file_url: "http://asset-manager.dev.gov.uk/media/45678/asset.txt",
        id: "123",
        name: "asset.txt",
        size: "12",
        state: "clean",
      }
    end

    subject do
      post_multipart "/assets", {
        asset: {
          file: fixture_file_upload("asset.txt", "text/plain"),
        },
      }
    end

    context "when Asset Manager responds with ok" do
      before do
        allow(Services.asset_manager).to receive(:create_asset).and_return(asset_manager_response.deep_stringify_keys)
      end

      context "when the request marks the asset as live" do
        let(:draft) { false }

        subject do
          post_multipart "/assets", {
            asset: {
              file: fixture_file_upload("asset.txt", "text/plain"),
              draft: false,
            },
          }
        end

        before do
          subject
        end

        it "responds with 201 Created" do
          expect(response).to have_http_status(:created)
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(asset_manager_response)
          expect(parsed_response).to include(asset_id: "45678")
        end

        it "does not include a token in the file_url" do
          expect(parsed_response[:file_url]).not_to match(/token=/)
        end
      end

      context "when the request marks the asset as draft" do
        before do
          allow(SecureRandom).to receive(:uuid).and_return("some-token")
          travel_to Time.zone.local(2026, 1, 1, 0, 0, 1)

          subject
        end

        it "responds with 201 Created" do
          expect(response).to have_http_status(:created)
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(asset_manager_response.except(:file_url))
          expect(parsed_response).to include(asset_id: "45678")
        end

        it "generates and includes a token in the file_url" do
          expected_decoded_token = {
            "exp" => Time.zone.local(2026, 1, 31, 0, 0, 1).to_i,
            "iat" => Time.zone.now.to_i,
            "sub" => "some-token",
          }

          expect(decoded_token_payload_from_url(parsed_response[:file_url])).to eq(expected_decoded_token)
        end

        it "includes a preview expiry date 30 days in the future" do
          expect(parsed_response).to include(preview_expiry: Time.zone.local(2026, 1, 31, 0, 0, 1).iso8601)
        end
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPPayloadTooLarge" do
      before do
        allow(Services.asset_manager).to receive(:create_asset).and_raise(GdsApi::HTTPPayloadTooLarge.new(413))

        subject
      end

      it "responds with 413 Content Too Large" do
        expect(response).to have_http_status(:content_too_large)
        expect(response.body).to include("Content exceeds maximum permitted size")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPUnprocessableEntity" do
      before do
        allow(Services.asset_manager).to receive(:create_asset).and_raise(GdsApi::HTTPUnprocessableEntity.new(422, "Some error message"))

        subject
      end

      it "responds with 422 Unprocessable Entity" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Some error message")
      end
    end

    context "when the Accept header is not application/json" do
      subject do
        post_multipart "/assets", {
          asset: {
            file: fixture_file_upload("asset.txt", "text/plain"),
          },
        }, { "HTTP_ACCEPT" => "text/plain" }
      end

      before do
        subject
      end

      it "responds with a 406 Not Acceptable" do
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    context "when Content-Type header is not multipart/form-data" do
      subject do
        post "/assets", params: {}, headers: {
          "CONTENT_TYPE" => "application/json",
          "HTTP_ACCEPT" => "application/json",
          "HTTP_AUTHORIZATION" => "Bearer 12345678",
        }
      end

      before do
        subject
      end

      it "responds with 415 Unsupported Media Type" do
        expect(response).to have_http_status(:unsupported_media_type)
      end
    end
  end

  describe "POST /assets/:id/regenerate-access" do
    let(:asset_manager_response) do
      {
        _response_info: {
          status: "ok",
        },
        content_type: "text",
        deleted: "false",
        draft: "false",
        file_url: "http://asset-manager.dev.gov.uk/media/123456789/asset.txt",
        id: "http://asset-manager/assets/123456789",
        name: "asset.txt",
        size: "12",
        state: "clean",
      }
    end

    subject do
      post "/assets/123456789/regenerate-access"
    end

    context "when Asset Manager responds with ok" do
      before do
        allow(Services.asset_manager).to receive(:update_asset).and_return(asset_manager_response.deep_stringify_keys)
        allow(SecureRandom).to receive(:uuid).and_return("new-token")
        travel_to Time.zone.local(2026, 1, 1, 0, 0, 1)

        subject
      end

      it "responds with 201 Created" do
        expect(response).to have_http_status(:created)
      end

      it "responds with data from Asset Manager" do
        expect(parsed_response).to include(asset_manager_response.except(:file_url))
      end

      it "generates and includes a token in the file_url" do
        expected_decoded_token = {
          "exp" => Time.zone.local(2026, 1, 31, 0, 0, 1).to_i,
          "iat" => Time.zone.now.to_i,
          "sub" => "new-token",
        }

        expect(decoded_token_payload_from_url(parsed_response[:file_url])).to eq(expected_decoded_token)
      end

      it "includes a preview expiry date 30 days in the future" do
        expect(parsed_response).to include(preview_expiry: Time.zone.local(2026, 1, 31, 0, 0, 1).iso8601)
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPNotFound" do
      before do
        allow(Services.asset_manager).to receive(:update_asset).and_raise(GdsApi::HTTPNotFound.new(404))

        subject
      end

      it "responds with 404 Not Found" do
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("Asset not found")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      before do
        allow(Services.asset_manager).to receive(:update_asset).and_raise(GdsApi::HTTPForbidden.new(403))

        subject
      end

      it "responds with 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("Access to asset is forbidden")
      end
    end
  end
end

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
