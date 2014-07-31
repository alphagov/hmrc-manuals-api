module ContentStoreDataHelpers
  def maximal_manual_for_content_store(options = {})
    {
      "base_path" => "/guidance/employment-income-manual",
      "format" => "hmrc-manual",
      "title" => "Employment Income Manual",
      "description" => "A manual about incoming employment",
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
                "description" => "A short description of the section",
                "base_path" => "/guidance/employment-income-manual/12345"
              }
            ]
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

  def maximal_section_for_content_store(options = {})
    {
      "base_path" => "/guidance/employment-income-manual/12345",
      "format" => "hmrc-manual-section",
      "title" => "A section on a part of employment income",
      "description" => "Some description",
      "public_updated_at" => "2014-01-23T00:00:00+01:00",
      "update_type" => "minor",
      "details" => {
        "body" => "I need somebody to love",
        "section_id" => "12345",
        "manual" => {
          "title" => "Employment Income Manual",
          "slug" => "employment-income-manual"
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
                "description" => "A short description of the section",
                "base_path" => "/guidance/employment-income-manual/123456"
              }
            ]
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

RSpec.configuration.include ContentStoreDataHelpers
