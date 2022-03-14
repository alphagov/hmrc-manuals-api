require "active_model"
require "struct_with_rendered_markdown"
require "valid_slug/pattern"

class PublishingAPIManual
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :to_h, no_dangerous_html_in_text_fields: true, if: -> { manual.valid? }
  validates :slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validates :slug, slug_in_known_manual_slugs: true, if: :only_known_hmrc_manual_slugs?
  validate :incoming_manual_is_valid

  attr_accessor :slug, :manual

  def initialize(slug, manual_attributes)
    @slug = slug
    @manual_attributes = Hash(manual_attributes)
    @manual = Manual.new(@manual_attributes)

    generate_content_id_if_absent
  end

  def to_h
    @to_h ||= begin
      enriched_data = @manual_attributes.except("content_id").deep_dup.merge(
        base_path: base_path,
        document_type: MANUAL_DOCUMENT_TYPE,
        schema_name: MANUAL_SCHEMA_NAME,
        publishing_app: "hmrc-manuals-api",
        rendering_app: "government-frontend",
        routes: [
          { path: base_path, type: :exact },
          { path: updates_path, type: :exact },
        ],
        locale: "en",
      )
      enriched_data = StructWithRenderedMarkdown.new(enriched_data).to_h
      enriched_data = add_base_path_to_child_section_groups(enriched_data)
      enriched_data = add_base_path_to_change_notes(enriched_data)
      enriched_data
    end
  end

  def links
    LinksBuilder.new(content_id).build_links
  end

  def content_id
    @manual_attributes["content_id"]
  end

  def update_type
    @manual_attributes["update_type"]
  end

  def govuk_url
    FRONTEND_BASE_URL + PublishingAPIManual.base_path(@slug)
  end

  def base_path
    PublishingAPIManual.base_path(@slug)
  end

  BASE_PATH_SEGMENT = "hmrc-internal-manuals".freeze

  def self.base_path(manual_slug)
    # The slug should be lowercase, but let's make sure
    "/#{BASE_PATH_SEGMENT}/#{manual_slug.to_s.downcase}"
  end

  def self.extract_slug_from_path(path)
    raise InvalidPathError if path.blank? || path !~ %r{\A/#{BASE_PATH_SEGMENT}/}

    slug = path.split("/", 4).third
    raise InvalidPathError if slug.blank?

    slug
  end

  def updates_path
    PublishingAPIManual.updates_path(@slug)
  end

  def self.updates_path(manual_slug)
    "#{base_path(manual_slug)}/updates"
  end

  def save!
    raise ValidationError, "manual is invalid" unless valid?

    PublishingAPINotifier.new(self).notify
  end

private

  def generate_content_id_if_absent
    @manual_attributes["content_id"] = base_path_uuid unless @manual_attributes["content_id"]
  end

  def add_base_path_to_child_section_groups(attributes)
    attributes["details"]["child_section_groups"].each do |section_group|
      section_group["child_sections"].each do |section|
        section["base_path"] = PublishingAPISection.base_path(@slug, section["section_id"])
      end
    end
    attributes
  end

  def add_base_path_to_change_notes(attributes)
    attributes["details"]["change_notes"] && attributes["details"]["change_notes"].each do |change_note_object|
      change_note_object["base_path"] = PublishingAPISection.base_path(@slug, change_note_object["section_id"])
    end
    attributes
  end

  def incoming_manual_is_valid
    unless @manual.valid?
      @manual.errors.full_messages.each { |message| errors.add(:base, message) }
    end
  end

  def only_known_hmrc_manual_slugs?
    !HMRCManualsAPI::Application.config.allow_unknown_hmrc_manual_slugs
  end
end
