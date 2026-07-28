require "rails_helper"

describe "assets resource" do
  include ActiveSupport::Testing::TimeHelpers

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

      context "when the asset is not draft" do
        let(:draft) { false }

        subject do
          post_multipart "/assets", {
            asset: {
              file: fixture_file_upload("asset.txt", "text/plain"),
              draft: false,
            },
          }
        end
        it "responds with 201 Created" do
          subject

          expect(response.status).to eq(201)
        end

        it "responds with data from asset manager" do
          subject

          parsed_response = JSON.parse(response.body).deep_symbolize_keys
          expect(parsed_response).to include(asset_manager_response)
          expect(parsed_response).to include(asset_id: "45678")
        end

        it "does not include a token in the file_url" do
          subject

          parsed_response = JSON.parse(response.body).deep_symbolize_keys
          expect(parsed_response[:file_url]).not_to match(/token=/)
        end
      end

      context "when the asset is draft" do
        before do
          allow(SecureRandom).to receive(:uuid).and_return("some-token")
        end

        it "responds with 201 Created" do
          subject

          expect(response.status).to eq(201)
        end

        it "responds with data from asset manager" do
          subject

          parsed_response = JSON.parse(response.body).deep_symbolize_keys
          expect(parsed_response).to include(asset_manager_response.except(:file_url))
          expect(parsed_response).to include(asset_id: "45678")
        end

        it "generates and includes a token in the file_url" do
          subject

          parsed_response = JSON.parse(response.body).deep_symbolize_keys
          expect(parsed_response).to include(file_url: "http://asset-manager.dev.gov.uk/media/45678/asset.txt?token=some-token")
        end

        it "includes a preview expiry date 30 days in the future" do
          travel_to Time.zone.local(2026, 1, 1, 0, 0, 1)
          subject

          parsed_response = JSON.parse(response.body).deep_symbolize_keys
          expect(parsed_response).to include(preview_expiry: Time.zone.local(2026, 1, 31, 0, 0, 1).iso8601)
        end
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPPayloadTooLarge" do
      before do
        allow(Services.asset_manager).to receive(:create_asset).and_raise(GdsApi::HTTPPayloadTooLarge.new(413))
      end

      it "returns a 413 response" do
        subject

        expect(response.status).to eq(413)
        expect(response.body).to include("Content exceeds maximum permitted size")
      end
    end

    context "when Asset Manager responds with GdsApi::HTTPUnprocessableEntity" do
      before do
        allow(Services.asset_manager).to receive(:create_asset).and_raise(GdsApi::HTTPUnprocessableEntity.new(422, "Some error message"))
      end

      it "returns a 422 response" do
        subject

        expect(response.status).to eq(422)
        expect(response.body).to include("Some error message")
      end
    end

    it "errors if the Accept header is not application/json" do
      allow(Services.asset_manager).to receive(:create_asset).and_return(asset_manager_response.deep_stringify_keys)

      post_multipart "/assets", {
        asset: {
          file: fixture_file_upload("asset.txt", "text/plain"),
        },
      }, { "HTTP_ACCEPT" => "text/plain" }
      expect(response.status).to eq(406)
    end

    it "errors if the Content-Type header is not multipart/form-data" do
      post "/assets", params: {}, headers: {
        "CONTENT_TYPE" => "application/json",
        "HTTP_ACCEPT" => "application/json",
        "HTTP_AUTHORIZATION" => "Bearer 12345678",
      }

      expect(response.status).to eq(415)
    end
  end
end
