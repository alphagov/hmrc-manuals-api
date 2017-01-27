class PublishingAPIRedirectedSectionToParentManual < PublishingAPIRedirectedSection
  def initialize(manual_slug, section_slug)
    super(manual_slug, section_slug, manual_slug)
  end

  def self.from_rummager_result(rummager_result)
    raise InvalidJSONError if rummager_result.blank? || rummager_result['link'].blank?
    slugs = PublishingAPISection.extract_slugs_from_path(rummager_result['link'])
    new(slugs[:manual], slugs[:section])
  end
end
