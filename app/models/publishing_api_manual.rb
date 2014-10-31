require 'active_model'
require 'struct_with_rendered_markdown'
require 'gds_api/publishing_api'
require 'valid_slug/pattern'

class PublishingAPIManual
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  FORMAT = 'hmrc_manual'

  validates :to_h, no_dangerous_html_in_text_fields: true, if: -> { manual.valid? }
  validates :slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validate :incoming_manual_is_valid

  attr_reader :slug, :manual

  def initialize(slug, manual_attributes)
    @slug = slug
    @manual_attributes = manual_attributes
    @manual = Manual.new(@manual_attributes)
  end

  def to_h
    @_to_h ||= begin
      enriched_data = @manual_attributes.deep_dup.merge({
        base_path: base_path,
        format: FORMAT,
        publishing_app: 'hmrc-manuals-api',
        rendering_app: 'manuals-frontend',
        routes: [
          { path: base_path, type: :exact },
          { path: updates_path, type: :exact }
        ]
        })
      enriched_data = StructWithRenderedMarkdown.new(enriched_data).to_h
      enriched_data = add_base_path_to_child_section_groups(enriched_data)
      enriched_data = add_organisations_to_details(enriched_data)
      add_base_path_to_change_notes(enriched_data)
    end
  end

  def govuk_url
    FRONTEND_BASE_URL + PublishingAPIManual.base_path(@slug)
  end

  def base_path
    PublishingAPIManual.base_path(@slug)
  end

  def self.base_path(manual_slug)
    # The slug should be lowercase, but let's make sure
    "/guidance/#{manual_slug.downcase}"
  end

  def updates_path
    PublishingAPIManual.updates_path(@slug)
  end

  def self.updates_path(manual_slug)
    base_path(manual_slug) + '/updates'
  end

  def save!
    raise ValidationError, "manual is invalid" unless valid?
    HMRCManualsAPI.publishing_api.put_content_item(base_path, to_h)

    rummager_manual = RummagerManual.new(to_h)
    HMRCManualsAPI.rummager.add_document(FORMAT, rummager_manual.id, rummager_manual.to_h)
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

  def incoming_manual_is_valid
    unless @manual.valid?
      @manual.errors.full_messages.each {|message| self.errors[:base] << message }
    end
  end
end
