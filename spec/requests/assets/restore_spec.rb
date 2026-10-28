require "rails_helper"

describe "POST /assets/:id/restore" do
  include_context "asset manager"

  let(:stub_asset_manager_request) { stub_asset_manager_restore_asset(asset_id, stubbed_asset_manager_response.deep_stringify_keys) }

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
      expect(parsed_response).to include(stubbed_asset_manager_response)
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
