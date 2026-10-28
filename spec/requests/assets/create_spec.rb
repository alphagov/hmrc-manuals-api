require "rails_helper"

describe "POST /assets" do
  include_context "asset manager"

  let(:draft) { true }
  let(:request_params) { { asset: { file: fixture_file_upload("asset.txt", "text/plain") } } }
  let(:file_url) { stubbed_asset_manager_response[:file_url] }
  let(:stub_asset_manager_request) { stub_asset_manager_create_asset(file_url, stubbed_asset_manager_response.deep_stringify_keys) }

  subject do
    post_multipart "/assets", request_params
  end

  before do
    allow(SecureRandom).to receive(:uuid).and_return("token")
    allow(Services.asset_manager).to receive(:create_asset).and_call_original
    stub_asset_manager_request

    subject
  end

  context "without a Content-Type header" do
    # post() has a Content-Type of application/x-www-form-urlencoded by default
    subject do
      Rack::MockRequest.new(Rails.application).post(
        "/assets",
        "HTTP_AUTHORIZATION" => "Bearer 12345678",
        "HTTP_ACCEPT" => "application/json",
      )
    end

    it "returns 415 Unsupported Media Type" do
      expect(subject).to have_http_status(:unsupported_media_type)
    end
  end

  context "when Asset Manager responds with ok" do
    context "when a value is not provided for draft" do
      around do |test|
        travel_to Time.zone.local(2026, 1, 1, 0, 0, 1) do
          test.run
        end
      end

      it "responds with 201 Created" do
        expect(response).to have_http_status(:created)
      end

      it "makes a request to Asset Manager" do
        expect(stub_asset_manager_request).to have_been_requested.once
      end

      it "responds with data from Asset Manager" do
        expect(parsed_response).to include(stubbed_asset_manager_response.except(:file_url))
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

      it_behaves_like "includes draft specific parameters"
    end

    context "when a value is provided for draft" do
      let(:request_params) { { asset: { file: fixture_file_upload("asset.txt", "text/plain"), draft: } } }

      context "when it's neither `true` nor `false`" do
        let(:draft) { "invalid" }

        it "responds with 400 Bad Request" do
          errors = expect_error_response(code: 400)
          expect(errors.first).to eq("'draft' needs to be either 'true' or 'false'")
        end
      end

      context "when the request marks the asset as live" do
        let(:draft) { false }

        it "responds with 201 Created" do
          expect(response).to have_http_status(:created)
        end

        it "makes a request to Asset Manager" do
          expect(stub_asset_manager_request).to have_been_requested.once
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(stubbed_asset_manager_response)
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

        around do |test|
          travel_to Time.zone.local(2026, 1, 1, 0, 0, 1) do
            test.run
          end
        end

        it "responds with 201 Created" do
          expect(response).to have_http_status(:created)
        end

        it "makes a request to Asset Manager" do
          expect(stub_asset_manager_request).to have_been_requested.once
        end

        it "responds with data from Asset Manager" do
          expect(parsed_response).to include(stubbed_asset_manager_response.except(:file_url))
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

        it_behaves_like "includes draft specific parameters"

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

  it_behaves_like "rejects unknown parameters"

  context "when the request does not include a file" do
    let(:request_params) { { asset: { draft: false } } }

    it "does not make a request to Asset Manager" do
      expect(response).to have_http_status(:bad_request)
      expect(stub_asset_manager_request).not_to have_been_requested
    end
  end

  context "when Asset Manager responds with GdsApi::HTTPPayloadTooLarge" do
    let(:stub_asset_manager_request) { stub_asset_manager_create_asset_too_large }

    it "responds with 413 Content Too Large" do
      errors = expect_error_response(code: 413)
      expect(errors.first).to eq("Content exceeds maximum permitted size")
    end
  end

  context "when Asset Manager responds with GdsApi::HTTPUnprocessableEntity" do
    let(:stub_asset_manager_request) { stub_asset_manager_create_asset_unprocessable("Some error message") }

    it "responds with 422 Unprocessable Entity" do
      errors = expect_error_response(code: 422)
      expect(errors.first).to include("Some error message")
    end
  end

  context "when the Accept header is not application/json" do
    subject do
      post_multipart "/assets", request_params, { "HTTP_ACCEPT" => "text/plain" }
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

    it "responds with 415 Unsupported Media Type" do
      errors = expect_error_response(code: 415)
      expect(errors.first).to eq("Invalid Content-Type header")
    end
  end
end
