require "active_model"
require "valid_slug/pattern"

class PublishingAPIRedirectedManual
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :manual_slug, :destination_manual_slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validates_with InContentStoreValidator,
    schema_name: MANUAL_SCHEMA_NAME,
    content_store: Services.content_store,
    unless: -> {
      errors[:manual_slug].present? || errors[:destination_manual_slug].present?
    }

  attr_accessor :manual_slug, :destination_manual_slug

  def initialize(manual_slug, destination_manual_slug)
    @manual_slug = manual_slug
    @destination_manual_slug = destination_manual_slug
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

  def base_path
    PublishingAPIManual.base_path(@manual_slug)
  end

  def redirect_to_location
    PublishingAPIManual.base_path(@destination_manual_slug)
  end

  def save!
    raise ValidationError, "manual section to redirect is invalid #{errors.full_messages.to_sentence}" unless valid?

    PublishingAPINotifier.new(self).notify(update_links: false)
  end

private

  def update_type
    "major"
  end
end
