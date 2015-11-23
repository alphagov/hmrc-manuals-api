module Helpers
  module PublishingAPIHelpers
    def add_organisations_to_details(attributes)
      attributes["details"].merge!(
        "organisations" => [
          {
            "title" => "HM Revenue & Customs",
            "abbreviation" => "HMRC",
            "web_url" => "https://www.gov.uk/government/organisations/hm-revenue-customs"
          }
        ]
      )
      attributes
    end

    def add_absent_content_id(attributes)
      unless attributes["content_id"]
        attributes["content_id"] = base_path_uuid
      end

      attributes
    end

    def base_path_uuid
      UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, base_path).to_s
    end
  end
end
