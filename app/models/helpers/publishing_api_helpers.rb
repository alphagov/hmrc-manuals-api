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
  end
end
