require 'rails_helper'

describe "validation" do
  let(:malformed_json) { "[" }
  let(:headers) { { 'Content-Type' => 'application/json' } }

  context "for manuals" do
    it "detects malformed JSON" do
      expect { put '/hmrc-manuals/imaginary-slug', malformed_json, headers }.to raise_exception(
        # This exception will translate to a 400 status code.
        ActionDispatch::ParamsParser::ParseError
      )
    end

    let(:manual_without_title) { { "foo" => "bar"} }

    it "validates for the presence of the title" do
      put_json '/hmrc-manuals/imaginary-slug', manual_without_title

      expect(response.status).to eq(422)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{The property '#/' did not contain a required property of 'title' in schema})
    end
  end

  context "for manual sections" do
    it "detects malformed JSON" do
      expect { put '/hmrc-manuals/imaginary-slug/sections/imaginary-section', malformed_json, headers }.to raise_exception(
        # This exception will translate to a 400 status code.
        ActionDispatch::ParamsParser::ParseError
      )
    end
  end
end
