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
  end

  context "for manual sections" do
    it "detects malformed JSON" do
      expect { put '/hmrc-manuals/imaginary-slug/imaginary-section', malformed_json, headers }.to raise_exception(
        # This exception will translate to a 400 status code.
        ActionDispatch::ParamsParser::ParseError
      )
    end
  end
end
