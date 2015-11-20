require 'active_model'
require 'struct_with_rendered_markdown'
require 'gds_api/publishing_api'
require 'valid_slug/pattern'
require 'topics'

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
    @topics = options.fetch(:topics, Topics.new(manual_slug: slug))
    @known_manual_slugs = options.fetch(:known_manual_slugs, MANUALS_TO_TOPICS.keys)
  end

  def to_h
    @_to_h ||= begin
      enriched_data = @manual_attributes.deep_dup.merge({
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
      enriched_data = add_absent_content_id(enriched_data)

      if HMRCManualsAPI::Application.config.publish_topics
        enriched_data = add_topic_links(enriched_data)
        enriched_data = add_topic_tags(enriched_data)
      end

      enriched_data
    end
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

  def topic_content_ids
    @topics.content_ids
  end

  def topic_slugs
    @topics.slugs
  end

  def save!
    raise ValidationError, "manual is invalid" unless valid?
    publishing_api_response = HMRCManualsAPI.publishing_api.put_content_item(base_path, to_h)

    rummager_manual = RummagerManual.new(base_path, to_h)
    rummager_manual.save!

    publishing_api_response
  end

private
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

  def add_topic_links(attributes)
    if topic_content_ids.present?
      attributes['links'] ||= {}
      attributes['links']['topics'] = topic_content_ids
    end

    attributes
  end

  def add_topic_tags(attributes)
    if topic_slugs.present?
      attributes['details']['tags'] ||= {}
      attributes['details']['tags']['topics'] = topic_slugs
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
