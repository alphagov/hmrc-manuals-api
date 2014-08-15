module PublishingApiDataHelpers
  def maximal_manual_for_publishing_api(options = {})
    {
      "base_path" => "/guidance/employment-income-manual",
      "format" => "hmrc-manual",
      "title" => "Employment Income Manual",
      "description" => "<p>A manual about incoming employment</p>\n",
      "public_updated_at" => "2014-01-23T00:00:00+01:00",
      "update_type" => "major",
      "details" => {
        "child_section_groups" => [
          {
            "title" => 'A group of sections',
            "child_sections" => [
              {
                "title" => "About 12345",
                "section_id" => "12345",
                "description" => "<p>A short description of the section</p>\n",
                "base_path" => "/guidance/employment-income-manual/12345"
              }
            ]
          }
        ],
        "organisations" => [
          {
            "title" => "HM Revenue & Customs",
            "abbreviation" => "HMRC",
            "web_url" => "https://www.gov.uk/government/organisations/hm-revenue-customs"
          }
        ],
        "change_notes" => [
          {
            "base_path" => "/guidance/employment-income-manual/abc567",
            "title" => 'Title of a Section that was changed',
            "section_id" => 'ABC567',
            "change_note" => 'Description of changes',
            "published_at" => '2014-01-23T00:00:00+01:00'
          }
        ]
      },
      "publishing_app" => "hmrc-manuals-api",
      "rendering_app" => "manuals-frontend",
      "routes" => [
        {
          "path" => "/guidance/employment-income-manual",
          "type" => "exact"
        }
      ]
    }.merge(options)
  end

  def maximal_section_for_publishing_api(options = {})
    {
      "base_path" => "/guidance/employment-income-manual/12345",
      "format" => "hmrc-manual-section",
      "title" => "A section on a part of employment income",
      "description" => "<p>Some description</p>\n",
      "public_updated_at" => "2014-01-23T00:00:00+01:00",
      "update_type" => "minor",
      "details" => {
        "body" => "<p>I need <strong>somebody</strong> to love</p>\n",
        "section_id" => "12345",
        "manual" => {
          "base_path" => "/guidance/employment-income-manual"
        },
        "breadcrumbs" => [
          {
            "section_id" => "1234",
            "base_path" => "/guidance/employment-income-manual/1234"
          }
        ],
        "child_section_groups" => [
          {
            "title" => 'A group of sections',
            "child_sections" => [
              {
                "title" => "About 123456",
                "section_id" => "123456",
                "description" => "<p>A short description of the section</p>\n",
                "base_path" => "/guidance/employment-income-manual/123456"
              }
            ]
          }
        ],
        "organisations" => [
          {
            "title" => "HM Revenue & Customs",
            "abbreviation" => "HMRC",
            "web_url" => "https://www.gov.uk/government/organisations/hm-revenue-customs"
          }
        ]
      },
      "publishing_app" => "hmrc-manuals-api",
      "rendering_app" => "manuals-frontend",
      "routes" => [
        {
          "path" => "/guidance/employment-income-manual/12345",
          "type" => "exact"
        }
      ]
    }.merge(options)
  end
end

RSpec.configuration.include PublishingApiDataHelpers
