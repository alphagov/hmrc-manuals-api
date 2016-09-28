require 'active_model'
require 'valid_slug/pattern'

class PublishingAPIRedirectedSectionToParentManual
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :manual_slug, :section_slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validates_with InContentStoreValidator,
    format: SECTION_FORMAT,
    content_store: Services.content_store,
    unless: -> {
      errors[:manual_slug].present? ||
        errors[:section_slug].present?
    }

  attr_accessor :manual_slug, :section_slug

  def self.from_rummager_result(rummager_result)
    raise InvalidJSONError if rummager_result.blank? || rummager_result['link'].blank?
    slugs = PublishingAPISection.extract_slugs_from_path(rummager_result['link'])
    new(slugs[:manual], slugs[:section])
  end

  def initialize(manual_slug, section_slug)
    @manual_slug = manual_slug
    @section_slug = section_slug
  end

  def to_h
    @_to_h ||= {
      document_type: 'redirect',
      schema_name: 'redirect',
      publishing_app: 'hmrc-manuals-api',
      base_path: base_path,
      redirects: [
        {
          path: base_path,
          type: "exact",
          destination: redirect_to_location
        }
      ],
    }
  end

  def content_id
    base_path_uuid
  end

  def update_type
    'major'
  end

  def base_path
    PublishingAPISection.base_path(manual_slug, section_slug)
  end

  def redirect_to_location
    PublishingAPIManual.base_path(manual_slug)
  end

  def save!
    raise ValidationError, "manual section to redirect is invalid #{errors.full_messages.to_sentence}" unless valid?
    PublishingAPINotifier.new(self).notify(update_links: false)
  end
end
