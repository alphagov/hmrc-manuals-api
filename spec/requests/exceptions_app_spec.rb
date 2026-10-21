require "rails_helper"

describe ExceptionsApp do
  let(:parsed_response) { JSON.parse(response.body).deep_symbolize_keys }

  # Emulate production environment
  around do |example|
    env_config = Rails.application.env_config
    prev_val = env_config["action_dispatch.show_detailed_exceptions"]
    env_config["action_dispatch.show_detailed_exceptions"] = false
    example.run
  ensure
    env_config["action_dispatch.show_detailed_exceptions"] = prev_val
  end

  context "with API paths" do
    context "when the request does not match a route" do
      it "responds with 404 Not Found and JSON output for /hmrc-manuals" do
        put "/hmrc-manuals/anything/non-existent"

        errors = expect_error_response(code: 404)
        expect(errors.first).to eq(%(No route matches [PUT] "/hmrc-manuals/anything/non-existent"))
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

      it "responds with 500 Internal Server Error and JSON output for /hmrc-manuals" do
        allow_any_instance_of(PublishingAPIManual).to receive(:save!).and_raise(RuntimeError, "boom")

        put_json "/hmrc-manuals/anything", valid_manual

        errors = expect_error_response(code: 500)
        expect(errors.first).to eq("Server error")
      end
    end
  end

  context "with non-API paths" do
    it "falls back to Rails' default error pages for unknown routes" do
      get "/definitely-non-existent"

      expect(response).to have_http_status(:not_found)
      expect(response.content_type).not_to eq("application/json")
    end

    it "falls back to Rails' default error pages for unknown healthcheck paths" do
      get "/healthcheck/non-existent"

      expect(response).to have_http_status(:not_found)
      expect(response.content_type).not_to eq("application/json")
    end
  end
end
