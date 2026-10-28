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
  shared_examples "includes a draft response token" do
    it "generates and includes a token in the file_url" do
      expected_decoded_token = {
        "exp" => Time.zone.local(2026, 1, 31, 0, 0, 1).to_i,
        "iat" => Time.zone.now.to_i,
        "sub" => "token",
      }

      expect(decoded_token_payload_from_url(parsed_response[:file_url])).to eq(expected_decoded_token)
    end

    it "includes a preview expiry date 30 days in the future" do
      expect(parsed_response).to include(preview_expiry: Time.zone.local(2026, 1, 31, 0, 0, 1).iso8601)
    end
  end

  shared_examples "rejects unknown parameters" do
    let(:request_params) do
      { asset: { non_existent: "value" } }
    end

    it "responds with 400 Bad Request" do
      errors = expect_error_response(code: 400)
      expect(errors.first).to eq("Unknown parameters: non_existent")
    end

    it "makes no requests to Asset Manager" do
      expect(stub_any_asset_manager_call).not_to have_been_requested
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
      errors = expect_error_response(code: 501)
      expect(errors.first).to eq("Asset manager requests are not allowed")
    end

    it "makes no requests to Asset Manager" do
      expect(stub_any_asset_manager_call).not_to have_been_requested
    end
  end

  describe "JSON error output" do
    # Emulate production environment
    around do |example|
      env_config = Rails.application.env_config
      prev_val = env_config["action_dispatch.show_detailed_exceptions"]
      env_config["action_dispatch.show_detailed_exceptions"] = false
      example.run
    ensure
      env_config["action_dispatch.show_detailed_exceptions"] = prev_val
    end

    context "when the request does not match any route" do
      it "responds with 404 Not Found and JSON output" do
        get "/assets/#{asset_id}/non-existent"

        errors = expect_error_response(code: 404)
        expect(errors.first).to eq(%(No route matches [GET] "/assets/#{asset_id}/non-existent"))
      end
    end

    context "when a required parameter is missing" do
      it "responds with 400 Bad Request and JSON output" do
        post_multipart "/assets", { asset: { draft: "true" } }

        errors = expect_error_response(code: 400)
        expect(errors.first).to eq("param is missing or the value is empty or invalid: file")
      end
    end

    context "when an unexpected error occurs" do
      around do |example|
        env_config = Rails.application.env_config
        prev_val = env_config["action_dispatch.show_exceptions"]
        env_config["action_dispatch.show_exceptions"] = :all
        example.run
      ensure
        env_config["action_dispatch.show_exceptions"] = prev_val
      end

      it "responds with 500 Internal Server Error and JSON output" do
        allow(Services.asset_manager).to receive(:asset).and_raise(RuntimeError, "boom")

        get "/assets/#{asset_id}"

        errors = expect_error_response(code: 500)
        expect(errors.first).to eq("Server error")
      end
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
        errors = expect_error_response(code: 404)
        expect(errors.first).to eq("Asset not found")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_request) { stub_asset_manager_get_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        errors = expect_error_response(code: 403)
        expect(errors.first).to eq("Access to asset is forbidden")
      end
    end
  end

  describe "POST /assets" do
    let(:draft) { true }
    let(:request_params) { { asset: { file: fixture_file_upload("asset.txt", "text/plain") } } }
    let(:file_url) { asset_manager_response[:file_url] }
    let(:stub_asset_manager_request) { stub_asset_manager_create_asset(file_url, asset_manager_response) }

    subject do
      post_multipart "/assets", request_params
    end

    context "without a Content-Type header" do
      it "returns 415 Unsupported Media Type" do
        # post() has a Content-Type of application/x-www-form-urlencoded by default
        response = Rack::MockRequest.new(Rails.application).post(
          "/assets",
          "HTTP_AUTHORIZATION" => "Bearer 12345678",
          "HTTP_ACCEPT" => "application/json",
        )

        expect(response).to have_http_status(:unsupported_media_type)
      end
    end

    context "when Asset Manager responds with ok" do
      before do
        allow(Services.asset_manager).to receive(:create_asset).and_call_original
        stub_asset_manager_request
      end

      context "when a value is not provided for draft" do
        before do
          allow(SecureRandom).to receive(:uuid).and_return("token")
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

        it "passes the correct params to Asset Manager" do
          expected = [{
            draft:, auth_bypass_ids: %w[token], file: an_instance_of(ActionDispatch::Http::UploadedFile)
          }]

          expect(Services.asset_manager).to have_received(:create_asset).with(*expected)
        end

        it_behaves_like "includes a draft response token"
      end

      context "when a value is provided for draft" do
        let(:request_params) { { asset: { file: fixture_file_upload("asset.txt", "text/plain"), draft: } } }

        subject do
          post_multipart "/assets", request_params
        end

        context "when it's neither `true` nor `false`" do
          let(:draft) { "invalid" }

          it "responds with 400 Bad Request" do
            subject
            errors = expect_error_response(code: 400)
            expect(errors.first).to eq("'draft' needs to be either 'true' or 'false'")
          end
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

          it "passes the correct params to Asset Manager" do
            expected = [{ draft:, file: an_instance_of(ActionDispatch::Http::UploadedFile) }]

            expect(Services.asset_manager).to have_received(:create_asset).with(*expected)
          end

          context "with mixed-case spelling" do
            let(:draft) { "False" }

            it "passes the correct params to Asset Manager" do
              expected = [{ draft: false, file: an_instance_of(ActionDispatch::Http::UploadedFile) }]

              expect(Services.asset_manager).to have_received(:create_asset).with(*expected)
            end
          end
        end

        context "when the request marks the asset as draft" do
          let(:draft) { true }

          before do
            allow(SecureRandom).to receive(:uuid).and_return("token")
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

          it "passes the correct params to Asset Manager" do
            expected = [{
              draft:, auth_bypass_ids: %w[token], file: an_instance_of(ActionDispatch::Http::UploadedFile)
            }]

            expect(Services.asset_manager).to have_received(:create_asset).with(*expected)
          end

          it_behaves_like "includes a draft response token"

          context "with mixed-case spelling" do
            let(:draft) { "True" }

            it "passes the correct params to Asset Manager" do
              expected = [{
                draft: true, auth_bypass_ids: %w[token], file: an_instance_of(ActionDispatch::Http::UploadedFile)
              }]

              expect(Services.asset_manager).to have_received(:create_asset).with(*expected)
            end
          end
        end
      end
    end

    context "when the request includes unknown parameters" do
      before do
        subject
      end

      it_behaves_like "rejects unknown parameters"
    end

    context "when the request does not include a file" do
      let(:request_params) { { asset: { draft: false } } }

      before do
        subject
      end

      it "does not make a request to Asset Manager" do
        expect(response).to have_http_status(:bad_request)
        expect(stub_asset_manager_request).not_to have_been_requested
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPPayloadTooLarge" do
      before do
        stub_asset_manager_create_asset_too_large

        subject
      end

      it "responds with 413 Content Too Large" do
        errors = expect_error_response(code: 413)
        expect(errors.first).to eq("Content exceeds maximum permitted size")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPUnprocessableEntity" do
      before do
        stub_asset_manager_create_asset_unprocessable("Some error message")

        subject
      end

      it "responds with 422 Unprocessable Entity" do
        errors = expect_error_response(code: 422)
        expect(errors.first).to include("Some error message")
      end
    end

    context "when the Accept header is not application/json" do
      subject do
        post_multipart "/assets", request_params, { "HTTP_ACCEPT" => "text/plain" }
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
        errors = expect_error_response(code: 415)
        expect(errors.first).to eq("Invalid Content-Type header")
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
        errors = expect_error_response(code: 404)
        expect(errors.first).to eq("Asset not found")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_request) { stub_asset_manager_delete_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        errors = expect_error_response(code: 403)
        expect(errors.first).to eq("Access to asset is forbidden")
      end
    end
  end

  describe "PUT /assets/:id" do
    let(:request_params) { { asset: { file: fixture_file_upload("asset.txt", "text/plain") } } }
    let(:stub_asset_manager_request) { stub_asset_manager_update_asset(asset_id, asset_manager_response.deep_stringify_keys) }
    let(:stub_asset_manager_get_request) { stub_asset_manager_request_to_get_asset(asset_id, { "draft": "false" }) }

    subject do
      put_multipart "/assets/#{asset_id}", request_params
    end

    before do
      allow(SecureRandom).to receive(:uuid).and_return("token")
      allow(Services.asset_manager).to receive(:update_asset).and_call_original
      stub_asset_manager_request
      stub_asset_manager_get_request

      subject
    end

    context "when Asset Manager responds with ok" do
      context "when the request includes a new file" do
        it "responds with 200 OK" do
          expect(response).to have_http_status(:ok)
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(asset_id:)
        end

        it "passes the correct params to Asset Manager" do
          expected = [asset_id, { file: an_instance_of(ActionDispatch::Http::UploadedFile) }]

          expect(Services.asset_manager).to have_received(:update_asset).with(*expected)
        end
      end

      context "when the client provides a value for draft" do
        let(:request_params) { { asset: { draft: } } }

        context "when it's neither `true` nor `false`" do
          let(:draft) { "invalid" }

          it "responds with 400 Bad Request" do
            subject
            errors = expect_error_response(code: 400)
            expect(errors.first).to eq("'draft' needs to be either 'true' or 'false'")
          end
        end

        context "when the asset is updated to not be draft" do
          let(:draft) { false }

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

          it "passes the correct params to Asset Manager" do
            expected = [asset_id, { draft: }]

            expect(Services.asset_manager).to have_received(:update_asset).with(*expected)
          end
        end

        context "when the asset is updated to be draft" do
          let(:draft) { true }

          around do |test|
            travel_to Time.zone.local(2026, 1, 1, 0, 0, 1) do
              test.run
            end
          end

          it "responds with 200 OK" do
            expect(response).to have_http_status(:ok)
          end

          it "responds with data from Asset Manager" do
            expect(parsed_response).to include(asset_manager_response.except(:file_url))
            expect(parsed_response).to include(asset_id:)
          end

          it "passes the correct params to Asset Manager" do
            expected = [asset_id, { draft:, auth_bypass_ids: %w[token] }]

            expect(Services.asset_manager).to have_received(:update_asset).with(*expected)
          end

          it_behaves_like "includes a draft response token"
        end
      end

      context "when no draft value is specified" do
        context "when the existing asset is draft" do
          let(:stub_asset_manager_get_request) { stub_asset_manager_request_to_get_asset(asset_id, { draft: true }) }

          around do |test|
            travel_to Time.zone.local(2026, 1, 1, 0, 0, 1) do
              test.run
            end
          end

          it "responds with 200 OK" do
            expect(response).to have_http_status(:ok)
          end

          it "responds with data from Asset Manager" do
            expect(parsed_response).to include(asset_manager_response.except(:file_url))
            expect(parsed_response).to include(asset_id:)
          end

          it "passes the correct params to Asset Manager" do
            expected = [asset_id,
                        { draft: true,
                          auth_bypass_ids: %w[token],
                          file: an_instance_of(ActionDispatch::Http::UploadedFile) }]

            expect(Services.asset_manager).to have_received(:update_asset).with(*expected)
          end

          it_behaves_like "includes a draft response token"
        end

        context "when the existing asset is not draft" do
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

          it "does not send a draft param to Asset Manager" do
            expected = [asset_id, { file: an_instance_of(ActionDispatch::Http::UploadedFile) }]

            expect(Services.asset_manager).to have_received(:update_asset).with(*expected)
          end
        end

        context "when the existing asset does not exist" do
          let(:stub_asset_manager_get_request) { stub_asset_manager_does_not_have_an_asset(asset_id) }

          it "responds with 404 Not Found" do
            errors = expect_error_response(code: 404)
            expect(errors.first).to eq("Asset does not exist")
          end
        end
      end

      context "when request params includes a replacement_id" do
        let(:additional_attributes) { { replacement_id: "987654321" } }
        let(:request_params) { { asset: additional_attributes } }

        it "responds with 200 OK" do
          expect(response).to have_http_status(:ok)
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(asset_id:)
        end

        it "passes the correct params to Asset Manager" do
          expected = [asset_id, additional_attributes]

          expect(Services.asset_manager).to have_received(:update_asset).with(*expected)
        end
      end
    end

    it_behaves_like "rejects unknown parameters"

    context "when Asset Manager responds with GdsApi::HTTPPayloadTooLarge" do
      let(:stub_asset_manager_request) { stub_asset_manager_update_asset_too_large(asset_id) }

      it "responds with 413 Content Too Large" do
        errors = expect_error_response(code: 413)
        expect(errors.first).to eq("Content exceeds maximum permitted size")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPNotFound" do
      let(:stub_asset_manager_get_request) { stub_asset_manager_does_not_have_an_asset(asset_id) }
      let(:stub_asset_manager_request) { stub_asset_manager_update_asset_not_found(asset_id) }

      it "responds with 404 Not Found" do
        errors = expect_error_response(code: 404)
        expect(errors.first).to eq("Asset does not exist")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_get_request) { stub_asset_manager_get_asset_forbidden(asset_id) }
      let(:stub_asset_manager_request) { stub_asset_manager_update_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        errors = expect_error_response(code: 403)
        expect(errors.first).to eq("Access to asset is forbidden")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPUnprocessableEntity" do
      let(:stub_asset_manager_request) { stub_asset_manager_update_asset_unprocessable(asset_id) }

      it "responds with 422 Unprocessable Entity" do
        errors = expect_error_response(code: 422)
        expect(errors.first).to eq("Asset update failed")
      end
    end

    context "when the Accept header is not application/json" do
      subject do
        put_multipart "/assets/#{asset_id}", request_params, { "HTTP_ACCEPT" => "text/plain" }
      end

      it "responds with 406 Not Acceptable" do
        expect(response).to have_http_status(:not_acceptable)
      end
    end

    context "when the content type header is not multipart/form-data" do
      subject do
        put "/assets/#{asset_id}", params: {}, headers: {
          "CONTENT_TYPE" => "application/json",
          "HTTP_ACCEPT" => "application/json",
          "HTTP_AUTHORIZATION" => "Bearer 12345678",
        }
      end

      it "responds with 415 Unsupported Media Type" do
        errors = expect_error_response(code: 415)
        expect(errors.first).to eq("Invalid Content-Type header")
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
      allow(SecureRandom).to receive(:uuid).and_return("token")
      travel_to Time.zone.local(2026, 1, 1, 0, 0, 1)

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
        expect(parsed_response).to include(asset_manager_response.except(:file_url))
      end

      it_behaves_like "includes a draft response token"
    end

    context "when Asset Manager responds with GdsApi::HTTPNotFound" do
      let(:stub_asset_manager_request) { stub_asset_manager_update_asset_not_found(asset_id) }

      it "responds with 404 Not Found" do
        errors = expect_error_response(code: 404)
        expect(errors.first).to eq("Asset not found")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPForbidden" do
      let(:stub_asset_manager_request) { stub_asset_manager_update_asset_forbidden(asset_id) }

      it "responds with 403 Forbidden" do
        errors = expect_error_response(code: 403)
        expect(errors.first).to eq("Access to asset is forbidden")
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
        errors = expect_error_response(code: 403)
        expect(errors.first).to eq("Access to asset is forbidden")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPNotFound" do
      let(:stub_asset_manager_request) { stub_asset_manager_restore_asset_not_found(asset_id) }

      it "responds with 404 Not Found" do
        errors = expect_error_response(code: 404)
        expect(errors.first).to eq("Asset not found")
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
