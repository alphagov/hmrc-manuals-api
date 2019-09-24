require "active_model"
require "valid_slug/pattern"

class PublishingAPIRemovedManual
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validates_with InContentStoreValidator,
                 schema_name: MANUAL_SCHEMA_NAME,
                 content_store: Services.content_store,
                 unless: -> { errors[:slug].present? }

  attr_accessor :slug

  def initialize(slug)
    @slug = slug
  end

  def sections
    SectionRetriever.new(slug).sections_from_rummager.map do |section_json|
      PublishingAPIRemovedSection.from_rummager_result(section_json)
    end
  end

  def to_h
    @_to_h ||= {
      base_path: base_path,
      document_type: "gone",
      schema_name: "gone",
      publishing_app: "hmrc-manuals-api",
      update_type: update_type,
      routes: [
        { path: base_path, type: :exact },
        { path: updates_path, type: :exact },
      ],
    }
  end

  def content_id
    base_path_uuid
  end

  def update_type
    "major"
  end

  def base_path
    PublishingAPIManual.base_path(@slug)
  end

  def updates_path
    PublishingAPIManual.updates_path(@slug)
  end

  def save!
    raise ValidationError, "manual to remove is invalid #{errors.full_messages.to_sentence}" unless valid?

    PublishingAPINotifier.new(self).notify(update_links: false)
  end
end
