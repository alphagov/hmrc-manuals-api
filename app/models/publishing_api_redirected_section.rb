require "active_model"
require "valid_slug/pattern"

class PublishingAPIRedirectedSection
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :manual_slug, :section_slug, :destination_manual_slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validates :destination_section_slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }, allow_nil: true
  validates_with InContentStoreValidator,
                 schema_name: SECTION_SCHEMA_NAME,
                 content_store: Services.content_store,
                 unless: -> {
                   errors[:manual_slug].present? ||
                     errors[:section_slug].present? ||
                     errors[:destination_manual_slug].present?
                 }

  attr_accessor :manual_slug, :section_slug, :destination_manual_slug, :destination_section_slug

  def initialize(manual_slug, section_slug, destination_manual_slug, destination_section_slug = nil)
    @manual_slug = manual_slug
    @section_slug = section_slug
    @destination_manual_slug = destination_manual_slug
    @destination_section_slug = destination_section_slug
  end

  def to_h
    @_to_h ||= {
      document_type: "redirect",
      schema_name: "redirect",
      publishing_app: "hmrc-manuals-api",
      base_path: base_path,
      redirects: [
        {
          path: base_path,
          type: "exact",
          destination: redirect_to_location,
        },
      ],
      update_type: update_type,
    }
  end

  def content_id
    base_path_uuid
  end

  def update_type
    "major"
  end

  def base_path
    PublishingAPISection.base_path(@manual_slug, @section_slug)
  end

  def redirect_to_location
    if destination_section_slug.present?
      PublishingAPISection.base_path(destination_manual_slug, destination_section_slug)
    else
      PublishingAPIManual.base_path(destination_manual_slug)
    end
  end

  def save!
    raise ValidationError, "manual section to redirect is invalid #{errors.full_messages.to_sentence}" unless valid?

    PublishingAPINotifier.new(self).notify(update_links: false)
  end
end
