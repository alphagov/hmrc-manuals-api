require "rails_helper"

describe "assets resource errors" do
  include_context "asset manager"

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
end
