require "rails_helper"

describe "Dangerous markup" do
  context "in manuals" do
    context "(disallowed HTML tags)" do
      let(:manual_with_script_tag_in_title) { valid_manual(title: "<script>text</script>") }

      it "invalidates free-text fields" do
        put_json "/hmrc-manuals/imaginary-slug", manual_with_script_tag_in_title

        expect(response.status).to eq(422)
        expect(json_response).to include("status" => "error")
        expect(json_response["errors"].first).to match(%r{'#/title' contains disallowed HTML})
      end
    end

    context "(dangerous markdown)" do
      let(:manual_with_dangerous_markdown_in_description) { valid_manual(description: "[link](javascript:alert())") }

      it "is invalid in descriptions" do
        put_json "/hmrc-manuals/imaginary-slug", manual_with_dangerous_markdown_in_description

        expect(response.status).to eq(422)
        expect(json_response).to include("status" => "error")
        expect(json_response["errors"].first).to match(%r{'#/description' contains disallowed HTML})
      end
    end
  end

  context "in sections" do
    context "(disallowed HTML tags)" do
      let(:section_with_disallowed_html_tag_in_title) { valid_section(title: "<script>text</script>") }

      it "is invalid in free-text fields" do
        put_json "/hmrc-manuals/imaginary-slug/sections/ABC", section_with_disallowed_html_tag_in_title

        expect(response.status).to eq(422)
        expect(json_response).to include("status" => "error")
        expect(json_response["errors"].first).to match(%r{'#/title' contains disallowed HTML})
      end
    end
  end
end
