require 'rails_helper'

describe "HTML markup" do
  context "within a manual" do
    let(:manual_with_html_tag_in_title) { valid_manual(title: '<b>text</b>') }

    it "is invalid in free-text fields" do
      put_json '/hmrc-manuals/imaginary-slug', manual_with_html_tag_in_title

      expect(response.status).to eq(422)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{'#/title' contains HTML})
    end
  end

  context "within a section" do
    let(:section_with_html_tag_in_title) { valid_section(title: '<b>text</b>') }

    it "is invalid in free-text fields" do
      put_json '/hmrc-manuals/imaginary-slug/sections/ABC', section_with_html_tag_in_title

      expect(response.status).to eq(422)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{'#/title' contains HTML})
    end
  end
end
