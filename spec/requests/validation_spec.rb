require "rails_helper"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/search"

describe "validation" do
  include GdsApi::TestHelpers::PublishingApi
  include GdsApi::TestHelpers::Search
  include LinksUpdateHelper

  let(:headers) { { "Content-Type" => "application/json", "HTTP_AUTHORIZATION" => "Bearer 12345678" } }
  let(:manual_without_title)  { valid_manual.tap { |m| m.delete("title") } }
  let(:section_without_title) { valid_section.tap { |m| m.delete("title") } }

  context "for manuals" do
    it "validates for the presence of the title" do
      put_json "/hmrc-manuals/imaginary-slug", manual_without_title

      expect(response.status).to eq(422)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{The property '#/' did not contain a required property of 'title' in schema})
    end

    context "manuals with images" do
      it "rejects manuals with Markdown images not on assets.digital.cabinet-office.gov.uk" do
        manual = valid_manual
        manual["description"] = "![Manual](http://upload.wikimedia.org/wikipedia/commons/e/ef/Icono_Normativa.png)"
        put_json "/hmrc-manuals/imaginary-slug", manual, headers

        expect(response.status).to eq(422)
      end

      it "rejects manuals with HTML images not on assets.digital.cabinet-office.gov.uk" do
        manual = valid_manual
        manual["description"] = '<img src="http://upload.wikimedia.org/wikipedia/commons/e/ef/Icono_Normativa.png" alt="Manual"/>'
        put_json "/hmrc-manuals/imaginary-slug", manual, headers

        expect(response.status).to eq(422)
      end

      it "allows images with a relative path" do
        content_id = UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, "/hmrc-internal-manuals/imaginary-slug").to_s
        stub_publishing_api_put_content(content_id, {}, body: { version: 22 })
        stub_publishing_api_get_links(content_id)
        stub_put_default_organisation(content_id)

        stub_publishing_api_publish(content_id, { update_type: nil, previous_version: 22 }.to_json)
        stub_any_search_post

        manual = valid_manual
        manual["description"] = "![Manual](/path/to/image.png)"
        put_json "/hmrc-manuals/imaginary-slug", manual, headers

        expect(response.status).to eq(200)
      end
    end
  end

  context "for manual sections" do
    it "validates for the presence of the title" do
      put_json "/hmrc-manuals/imaginary-slug/sections/imaginary-section", section_without_title

      expect(response.status).to eq(422)
      expect(json_response).to include("status" => "error")
      expect(json_response["errors"].first).to match(%r{The property '#/' did not contain a required property of 'title' in schema})
    end
  end
end
