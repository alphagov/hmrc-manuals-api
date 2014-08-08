require 'active_model'
require 'struct_with_rendered_markdown'
require 'gds_api/publishing_api'
require 'valid_slug/pattern'

class PublishingAPIManual
  include ActiveModel::Validations

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
    enriched_data = @manual_attributes.deep_dup.merge({
      base_path: PublishingAPIManual.base_path(@slug),
      format: 'hmrc-manual',
      publishing_app: 'hmrc-manuals-api',
      rendering_app: 'manuals-frontend',
      routes: [{ path: PublishingAPIManual.base_path(@slug), type: :exact }]
      })
    enriched_data = StructWithRenderedMarkdown.new(enriched_data).to_h
    add_base_path_to_child_section_groups(enriched_data)
  end

  def govuk_url
    Plek.current.website_root + PublishingAPIManual.base_path(@slug)
  end

  def self.base_path(manual_slug)
    "/guidance/#{manual_slug}"
  end

  def save!
    raise ValidationError, "manual is invalid" unless valid?
    HMRCManualsAPI.publishing_api.put_content_item(PublishingAPIManual.base_path(@slug), to_h)
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

  def incoming_manual_is_valid
    unless @manual.valid?
      @manual.errors.full_messages.each {|message| self.errors[:base] << message }
    end
  end
end
