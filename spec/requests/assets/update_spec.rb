require "rails_helper"

describe "PUT /assets/:id" do
  include_context "asset manager"

  let(:request_params) { { asset: { file: fixture_file_upload("asset.txt", "text/plain") } } }
  let(:stub_asset_manager_request) { stub_asset_manager_update_asset(asset_id, stubbed_asset_manager_response.deep_stringify_keys) }
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
          expect(parsed_response).to include(stubbed_asset_manager_response)
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
          expect(parsed_response).to include(stubbed_asset_manager_response.except(:file_url))
          expect(parsed_response).to include(asset_id:)
        end

        it "passes the correct params to Asset Manager" do
          expected = [asset_id, { draft:, auth_bypass_ids: %w[token] }]

          expect(Services.asset_manager).to have_received(:update_asset).with(*expected)
        end

        it_behaves_like "includes draft specific parameters"
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
          expect(parsed_response).to include(stubbed_asset_manager_response.except(:file_url))
          expect(parsed_response).to include(asset_id:)
        end

        it "passes the correct params to Asset Manager" do
          expected = [asset_id,
                      { draft: true,
                        auth_bypass_ids: %w[token],
                        file: an_instance_of(ActionDispatch::Http::UploadedFile) }]

          expect(Services.asset_manager).to have_received(:update_asset).with(*expected)
        end

        it_behaves_like "includes draft specific parameters"
      end

      context "when the existing asset is not draft" do
        it "responds with 200 OK" do
          expect(response).to have_http_status(:ok)
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(stubbed_asset_manager_response)
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
