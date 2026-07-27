require "rails_helper"

describe "assets resource" do
  describe "POST /assets" do
    let(:asset_manager_response) do
      {
        _response_info: {
          status: "ok",
        },
        content_type: "text",
        deleted: "false",
        draft: "false",
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

    before do
      allow(Services.asset_manager).to receive(:create_asset).and_return(asset_manager_response.deep_stringify_keys)
    end

    context "when Asset Manager responds with ok" do
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
    end

    it "errors if the Accept header is not application/json" do
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
