require "rails_helper"

describe "authentication" do
  around do |spec|
    ENV["GDS_SSO_MOCK_INVALID"] = "true"
    spec.run
    ENV.delete("GDS_SSO_MOCK_INVALID")
  end

  it "returns 401 JSON if no bearer token is present" do
    put_json "/hmrc-manuals/imaginary-slug", valid_manual, "HTTP_AUTHORIZATION" => ""

    errors = expect_error_response(code: 401)
    expect(errors.first).to eq("No bearer token was provided")
  end

  it "returns 401 JSON for unauthenticated GET requests" do
    get "/assets/0ebc9800-94c4-013f-fb0a-72f4e816b13f"

    errors = expect_error_response(code: 401)
    expect(response.headers["WWW-Authenticate"]).to eq('Bearer error="invalid_request"')
    expect(errors.first).to eq("No bearer token was provided")
  end

  it "returns 401 JSON if the bearer token is invalid" do
    get "/assets/0ebc9800-94c4-013f-fb0a-72f4e816b13f",
        headers: { "HTTP_AUTHORIZATION" => "Bearer invalid-token" }

    errors = expect_error_response(code: 401)
    expect(response.headers["WWW-Authenticate"]).to eq('Bearer error="invalid_token"')
    expect(errors.first).to eq("Bearer token does not appear to be valid")
  end
end
