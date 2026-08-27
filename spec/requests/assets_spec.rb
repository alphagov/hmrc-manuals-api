require "rails_helper"
require "gds_api/test_helpers/asset_manager"

describe "assets resource" do
  include ActiveSupport::Testing::TimeHelpers
  include GdsApi::TestHelpers::AssetManager

  let(:asset_id) { SecureRandom.hex }
  let(:additional_attributes) { {} }
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
    }.merge(additional_attributes)
  end
  let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

  shared_examples "passes the correct params to Asset Manager" do
    it "passes forward params" do
      expected_params = request_params.fetch(:asset).dup
      expected_params[:file] = an_instance_of(Tempfile) if expected_params.key?(:file)

      expect(Services.asset_manager).to have_received(:update_asset).with(asset_id, hash_including(expected_params))
    end
  end

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
        expect(parsed_response).to eq({ errors: "Asset not found", status: "error" })
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_request) { stub_asset_manager_get_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(parsed_response).to eq({ errors: "Access to asset is forbidden", status: "error" })
      end
    end
  end

  describe "POST /assets" do
    let(:draft) { true }
    let(:file_url) { asset_manager_response[:file_url] }
    let(:stub_asset_manager_request) { stub_asset_manager_create_asset(file_url, asset_manager_response) }

    subject do
      post_multipart "/assets", {
        asset: {
          file: fixture_file_upload("asset.txt", "text/plain"),
        },
      }
    end

    context "when Asset Manager responds with ok" do
      before do
        stub_asset_manager_request
      end

      context "when a value is not provided for draft" do
        before do
          allow(SecureRandom).to receive(:uuid).and_return("some-token")
          travel_to Time.zone.local(2026, 1, 1, 0, 0, 1)

          subject
        end

        it "responds with 201 Created" do
          expect(response).to have_http_status(:created)
        end

        it "makes a request to Asset Manager" do
          expect(stub_asset_manager_request).to have_been_requested.once
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(asset_manager_response.except(:file_url))
        end

        it "includes the file_url" do
          expect(parsed_response[:file_url]).to match(/#{file_url}/)
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

      context "when a value is provided for draft" do
        subject do
          post_multipart "/assets", {
            asset: {
              file: fixture_file_upload("asset.txt", "text/plain"),
              draft:,
            },
          }
        end

        context "when the request marks the asset as live" do
          let(:draft) { false }

          before do
            subject
          end

          it "responds with 201 Created" do
            expect(response).to have_http_status(:created)
          end

          it "makes a request to Asset Manager" do
            expect(stub_asset_manager_request).to have_been_requested.once
          end

          it "responds with data from Asset Manager" do
            expect(parsed_response).to include(asset_manager_response)
          end

          it "includes the asset_id" do
            expect(parsed_response).to include(asset_id:)
          end

          it "does not include a token in the file_url" do
            expect(parsed_response[:file_url]).not_to match(/token=/)
          end
        end

        context "when the request marks the asset as draft" do
          let(:draft) { true }

          before do
            allow(SecureRandom).to receive(:uuid).and_return("some-token")
            travel_to Time.zone.local(2026, 1, 1, 0, 0, 1)

            subject
          end

          it "responds with 201 Created" do
            expect(response).to have_http_status(:created)
          end

          it "makes a request to Asset Manager" do
            expect(stub_asset_manager_request).to have_been_requested.once
          end

          it "responds with data from Asset Manager" do
            expect(parsed_response).to include(asset_manager_response.except(:file_url))
          end

          it "includes the file_url" do
            expect(parsed_response[:file_url]).to match(/#{file_url}/)
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
    end

    context "when the request does not include a file" do
      subject do
        post_multipart "/assets", {
          asset: {
            draft: false,
          },
        }
      end

      before do
        subject
      end

      it "responds with 400 Bad Request" do
        expect(response).to have_http_status(:bad_request)
      end

      it "does not make a request to Asset Manager" do
        expect(stub_asset_manager_request).not_to have_been_requested
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPPayloadTooLarge" do
      before do
        stub_asset_manager_create_asset_too_large

        subject
      end

      it "responds with 413 Content Too Large" do
        expect(response).to have_http_status(:content_too_large)
        expect(parsed_response).to eq({ errors: "Content exceeds maximum permitted size", status: "error" })
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPUnprocessableEntity" do
      before do
        stub_asset_manager_create_asset_unprocessable("Some error message")

        subject
      end

      it "responds with 422 Unprocessable Entity" do
        expect(response).to have_http_status(:unprocessable_content)
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

  describe "DELETE /assets/:id" do
    let(:stub_asset_manager_request) { stub_asset_manager_delete_asset(asset_id, asset_manager_response.deep_stringify_keys) }

    subject do
      delete "/assets/#{asset_id}"
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
      let(:stub_asset_manager_request) { stub_asset_manager_delete_asset_missing(asset_id) }

      it "responds with 404 Not Found" do
        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to eq({ errors: "Asset not found", status: "error" })
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_request) { stub_asset_manager_delete_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(parsed_response).to eq({ errors: "Access to asset is forbidden", status: "error" })
      end
    end
  end

  describe "PUT /assets/:id" do
    let(:request_params) { { asset: { file: fixture_file_upload("asset.txt", "text/plain") } } }
    let(:stub_asset_manager_request) { stub_asset_manager_update_asset(asset_id, asset_manager_response.deep_stringify_keys) }
    subject do
      put_multipart "/assets/#{asset_id}", request_params
    end

    context "when Asset Manager responds with ok" do
      before do
        allow(Services.asset_manager).to receive(:update_asset).and_call_original
        stub_asset_manager_request
      end

      context "when the request includes a new file" do
        before do
          subject
        end

        it "responds with 200 OK" do
          expect(response).to have_http_status(:ok)
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(asset_id:)
        end

        it_behaves_like "passes the correct params to Asset Manager"
      end

      context "when the client provides a value for draft" do
        let(:request_params) { { asset: { draft: draft } } }

        context "when the asset is not draft" do
          let(:draft) { false }

          before do
            subject
          end

          it "responds with 200 OK" do
            expect(response).to have_http_status(:ok)
          end

          it "responds with data from Asset Manager" do
            expect(parsed_response).to include(asset_manager_response)
            expect(parsed_response).to include(asset_id:)
          end

          it "does not include a token in the file_url" do
            expect(parsed_response[:file_url]).not_to match(/token=/)
          end

          it_behaves_like "passes the correct params to Asset Manager"
        end

        context "when the asset is draft" do
          let(:draft) { true }

          before do
            allow(SecureRandom).to receive(:uuid).and_return("some-token")
            travel_to Time.zone.local(2026, 1, 1, 0, 0, 1)

            subject
          end

          it "responds with 200 OK" do
            expect(response).to have_http_status(:ok)
          end

          it "responds with data from Asset Manager" do
            expect(parsed_response).to include(asset_manager_response.except(:file_url))
            expect(parsed_response).to include(asset_id:)
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

          it_behaves_like "passes the correct params to Asset Manager"
        end
      end

      context "when request params includes a replacement_id" do
        let(:additional_attributes) { { replacement_id: "987654321" } }
        let(:request_params) { { asset: additional_attributes } }

        before do
          subject
        end

        it "responds with 200 OK" do
          expect(response).to have_http_status(:ok)
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(asset_id:)
        end

        it_behaves_like "passes the correct params to Asset Manager"
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPPayloadTooLarge" do
      before do
        stub_asset_manager_update_asset_too_large(asset_id)

        subject
      end

      it "responds with 413 Content Too Large" do
        expect(response).to have_http_status(:content_too_large)
        expect(parsed_response).to eq({ errors: "Content exceeds maximum permitted size", status: "error" })
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPNotFound" do
      before do
        stub_asset_manager_update_asset_not_found(asset_id)

        subject
      end

      it "responds with 404 Not Found" do
        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to eq({ errors: "Asset does not exist", status: "error" })
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      before do
        stub_asset_manager_update_asset_forbidden(asset_id)

        subject
      end

      it "responds with 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(parsed_response).to eq({ errors: "Access to asset is forbidden", status: "error" })
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPUnprocessableEntity" do
      before do
        stub_asset_manager_update_asset_unprocessable(asset_id)

        subject
      end

      it "responds with 422 Unprocessable Entity" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response).to eq({ errors: "Asset update failed", status: "error" })
      end
    end

    context "when the Accept header is not application/json" do
      subject do
        put_multipart "/assets/12345", request_params, { "HTTP_ACCEPT" => "text/plain" }
      end

      before do
        subject
      end

      it "responds with 406 Not Acceptable" do
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    context "when the content type header is not multipart/form-data" do
      subject do
        put "/assets/12345", params: {}, headers: {
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
    let(:stub_asset_manager_request) { stub_asset_manager_update_asset(asset_id, asset_manager_response.deep_stringify_keys) }

    subject do
      post "/assets/#{asset_id}/regenerate-access"
    end

    before do
      stub_asset_manager_request
      allow(SecureRandom).to receive(:uuid).and_return("new-token")
      travel_to Time.zone.local(2026, 1, 1, 0, 0, 1)

      subject
    end

    context "when Asset Manager responds with ok" do
      it "responds with 201 Created" do
        expect(response).to have_http_status(:created)
      end

      it "makes a request to Asset Manager" do
        expect(stub_asset_manager_request).to have_been_requested.once
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
      let(:stub_asset_manager_request) { stub_asset_manager_update_asset_not_found(asset_id) }

      it "responds with 404 Not Found" do
        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to eq({ errors: "Asset not found", status: "error" })
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_request) { stub_asset_manager_update_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(parsed_response).to eq({ errors: "Access to asset is forbidden", status: "error" })
      end
    end
  end

  describe "POST /assets/:id/restore" do
    let(:stub_asset_manager_request) { stub_asset_manager_restore_asset(asset_id, asset_manager_response.deep_stringify_keys) }

    subject do
      post "/assets/#{asset_id}/restore"
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

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_request) { stub_asset_manager_restore_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
        expect(parsed_response).to eq({ errors: "Access to asset is forbidden", status: "error" })
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPNotFound" do
      let(:stub_asset_manager_request) { stub_asset_manager_restore_asset_not_found(asset_id) }

      it "responds with 404 Not Found" do
        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to eq({ errors: "Asset not found", status: "error" })
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
