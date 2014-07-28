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
end

RSpec.configuration.include ContentStoreDataHelpers
