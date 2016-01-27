require 'active_model'
require 'valid_slug/pattern'

class PublishingAPIRemovedSection
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :manual_slug, :section_slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validates_with InContentStoreValidator,
    format: SECTION_FORMAT,
    content_store: Services.content_store,
    unless: -> { errors[:manual_slug].present? || errors[:section_slug].present? }

  attr_reader :manual_slug, :section_slug

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
      base_path: base_path,
      format: 'gone',
      publishing_app: 'hmrc-manuals-api',
      update_type: update_type,
      routes: [
        { path: base_path, type: :exact },
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
    PublishingAPISection.base_path(@manual_slug, @section_slug)
  end

  def save!
    raise ValidationError, "manual section to remove is invalid #{errors.full_messages.to_sentence}" unless valid?
    publishing_api_response = PublishingAPINotifier.new(self).notify
    Services.rummager.delete_document(SECTION_FORMAT, base_path)
    publishing_api_response
  end
end
