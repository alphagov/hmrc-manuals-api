class PublishingAPIRedirectedSectionToParentManual < PublishingAPIRedirectedSection
  def initialize(manual_slug, section_slug)
    super(manual_slug, section_slug, manual_slug)
  end

  def self.from_search_api_result(search_api_result)
    raise InvalidJSONError if search_api_result.blank? || search_api_result["link"].blank?

    slugs = PublishingAPISection.extract_slugs_from_path(search_api_result["link"])
    new(slugs[:manual], slugs[:section])
  end
end
