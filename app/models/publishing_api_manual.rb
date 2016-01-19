require 'active_model'
require 'struct_with_rendered_markdown'
require 'valid_slug/pattern'

class PublishingAPIManual
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :to_h, no_dangerous_html_in_text_fields: true, if: -> { manual.valid? }
  validates :slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validates :slug, slug_in_known_manual_slugs: true, if: :only_known_hmrc_manual_slugs?
  validate :incoming_manual_is_valid

  attr_reader :slug, :manual, :known_manual_slugs

  def initialize(slug, manual_attributes, options = {})
    @slug = slug
    @manual_attributes = manual_attributes
    @manual = Manual.new(@manual_attributes)
    @known_manual_slugs = options.fetch(:known_manual_slugs, MANUALS_TO_TOPICS.keys)
    generate_content_id_if_absent
  end

  def to_h
    @_to_h ||= begin
      enriched_data = @manual_attributes.except('content_id', 'update_type').deep_dup.merge({
        base_path: base_path,
        format: MANUAL_FORMAT,
        publishing_app: 'hmrc-manuals-api',
        rendering_app: 'manuals-frontend',
        routes: [
          { path: base_path, type: :exact },
          { path: updates_path, type: :exact }
        ],
        locale: "en",
      })
      enriched_data = StructWithRenderedMarkdown.new(enriched_data).to_h
      enriched_data = add_base_path_to_child_section_groups(enriched_data)
      enriched_data = add_organisations_to_details(enriched_data)
      enriched_data = add_base_path_to_change_notes(enriched_data)
      enriched_data
    end
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

  BASE_PATH_SEGMENT = 'hmrc-internal-manuals'

  def self.base_path(manual_slug)
    # The slug should be lowercase, but let's make sure
    "/#{BASE_PATH_SEGMENT}/#{manual_slug.downcase}"
  end

  def self.extract_slug_from_path(path)
    raise InvalidPathError if path.blank? || path !~ %r{\A/#{BASE_PATH_SEGMENT}/}
    slug = path.split('/',4).third
    raise InvalidPathError if slug.blank?
    slug
  end

  def updates_path
    PublishingAPIManual.updates_path(@slug)
  end

  def self.updates_path(manual_slug)
    base_path(manual_slug) + '/updates'
  end

  def save!
    raise ValidationError, "manual is invalid" unless valid?
    publishing_api_response = PublishingAPINotifier.new(self).notify
    rummager_manual = RummagerManual.new(base_path, to_h)
    rummager_manual.save!
    publishing_api_response
  end

private

  def generate_content_id_if_absent
    if @manual_attributes.is_a?(Hash)
      @manual_attributes["content_id"] = base_path_uuid unless @manual_attributes["content_id"]
    end
  end

  def add_base_path_to_child_section_groups(attributes)
    attributes["details"]["child_section_groups"].each do |section_group|
      section_group["child_sections"].each do |section|
        section['base_path'] = PublishingAPISection.base_path(@slug, section['section_id'])
      end
    end
    attributes
  end

  def add_base_path_to_change_notes(attributes)
    attributes["details"]["change_notes"] && attributes["details"]["change_notes"].each do |change_note_object|
      change_note_object['base_path'] = PublishingAPISection.base_path(@slug, change_note_object['section_id'])
    end
    attributes
  end

  def incoming_manual_is_valid
    unless @manual.valid?
      @manual.errors.full_messages.each {|message| self.errors[:base] << message }
    end
  end

  def only_known_hmrc_manual_slugs?
    !HMRCManualsAPI::Application.config.allow_unknown_hmrc_manual_slugs
  end
end
