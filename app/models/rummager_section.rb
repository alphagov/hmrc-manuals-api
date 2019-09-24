class RummagerSection
  GOVUK_HMRC_SLUG = "hm-revenue-customs".freeze

  def self.search_query(manual_path, start = 0, count = 1000)
    {
      "filter_format" => SECTION_SCHEMA_NAME,
      "filter_organisations" => GOVUK_HMRC_SLUG,
      "filter_manual" => manual_path,
      "count" => count,
      "start" => start,
    }
  end
end
