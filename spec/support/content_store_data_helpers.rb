module ContentStoreDataHelpers
  def valid_manual_for_content_store(options = {})
    {
      "base_path" => "/guidance/employment-income-manual",
      "format" => "hmrc-manual",
      "title" => "Employment Income Manual",
      "description" => "A manual about incoming employment",
      "public_updated_at" => "2014-01-23T00:00:00+01:00",
      "update_type" => "minor",
      "details" => {
        "child_section_groups" => []
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
