require "rails_helper"

describe "POST /assets/:id/regenerate-access" do
  include_context "asset manager"

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

    it_behaves_like "includes draft specific parameters"
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
