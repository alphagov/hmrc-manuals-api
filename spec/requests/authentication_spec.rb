require "rails_helper"

describe "authentication" do
  around do |spec|
    ENV["GDS_SSO_MOCK_INVALID"] = "true"
    spec.run
    ENV.delete("GDS_SSO_MOCK_INVALID")
  end

  # FIXME: This isn't ideal, we now determine an api call by the presence of a
  # bearer token in the gds-sso gem, if this isn't present the default Warden
  # strategy is used (in test mode this takes the first user from the db).
  # With the mock user disabled the default strategy redirects the user to /auth/gds.
  # Despite this I'm leaving this test in place to highlight the problem of
  # a broken redirect.
  it "redirects to /auth/gds if no bearer token is present" do
    put_json "/hmrc-manuals/imaginary-slug", valid_manual, "HTTP_AUTHORIZATION" => ""

    expect(response).to redirect_to(/\/auth\/gds/)
  end
end
