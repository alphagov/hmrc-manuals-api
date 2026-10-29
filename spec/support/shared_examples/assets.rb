RSpec.shared_examples "includes draft specific parameters" do
  it "generates and includes a token in the file_url" do
    expected_decoded_token = {
      "exp" => Time.zone.local(2026, 1, 31, 0, 0, 1).to_i,
      "iat" => Time.zone.now.to_i,
      "sub" => "token",
    }

    expect(decoded_token_payload_from_url(parsed_response[:file_url])).to eq(expected_decoded_token)
  end

  it "includes a preview expiry date 30 days in the future" do
    expect(parsed_response).to include(preview_expiry: Time.zone.local(2026, 1, 31, 0, 0, 1).iso8601)
  end

  it "does not include duplicate file_url keys" do
    expect(response.body.scan(/"file_url":/).count).to eq(1)
  end
end

RSpec.shared_examples "rejects unknown parameters" do
  let(:request_params) do
    { asset: { non_existent: "value" } }
  end

  it "responds with 400 Bad Request" do
    errors = expect_error_response(code: 400)
    expect(errors.first).to eq("Unknown parameters: non_existent")
  end

  it "makes no requests to Asset Manager" do
    expect(stub_any_asset_manager_call).not_to have_been_requested
  end
end

RSpec.shared_examples "rejects malformed asset params" do |request_params:|
  let(:request_params) { request_params }

  it "responds with 400 Bad Reqest" do
    expect_error_response(code: 400)
  end

  it "make no requests to Asset Manager" do
    expect(stub_any_asset_manager_call).not_to have_been_requested
  end
end

RSpec.shared_examples "rejects missing asset root" do
  let(:request_params) { { "other" => "value" } }

  it "responds with 400 Bad Reqest" do
    expect(response).to have_http_status(:bad_request)
  end

  it "make no requests to Asset Manager" do
    expect(stub_any_asset_manager_call).not_to have_been_requested
  end
end
