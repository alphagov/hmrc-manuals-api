require 'active_model'
require 'gds_api/publishing_api'
require 'struct_with_rendered_markdown'
require 'valid_slug/pattern'

class PublishingAPISection
  include ActiveModel::Validations

  validates :to_h, no_dangerous_html_in_text_fields: true, if: -> { @section.valid? }
  validates :manual_slug, :section_slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validate :incoming_section_is_valid

  attr_reader :manual_slug, :section_slug

  def initialize(manual_slug, section_slug, section_attributes)
    @manual_slug = manual_slug
    @section_slug = section_slug
    @section_attributes = section_attributes
    @section = Section.new(section_attributes)
  end

  def to_h
    enriched_data = @section_attributes.deep_dup.merge({
      base_path: PublishingAPISection.base_path(@manual_slug, @section_slug),
      format: 'hmrc-manual-section',
      publishing_app: 'hmrc-manuals-api',
      rendering_app: 'manuals-frontend',
      routes: [{ path: PublishingAPISection.base_path(@manual_slug, @section_slug), type: :exact }]
      })
    enriched_data = StructWithRenderedMarkdown.new(enriched_data).to_h
    enriched_data = add_base_path_to_child_section_groups(enriched_data)
    enriched_data = add_base_path_to_breadcrumbs(enriched_data)
    add_base_path_to_manual(enriched_data)
  end

  def govuk_url
    Plek.current.website_root + PublishingAPISection.base_path(@manual_slug, @section_slug)
  end

  def self.base_path(manual_slug, section_slug)
    File.join(PublishingAPIManual.base_path(manual_slug), section_slug)
  end

  def save!
    raise ValidationError, "section is invalid" unless valid?

    HMRCManualsAPI.publishing_api.put_content_item(
      PublishingAPISection.base_path(@manual_slug, @section_slug), to_h)
  end

private
  def add_base_path_to_child_section_groups(attributes)
    # child_section_groups isn't required for sections, so might be nil:
    (attributes["details"]["child_section_groups"] || []).each do |section_group|
      section_group["child_sections"].each do |section|
        section['base_path'] = PublishingAPISection.base_path(@manual_slug, section['section_id'])
      end
    end
    attributes
  end

  def add_base_path_to_breadcrumbs(attributes)
    # breadcrumbs isn't required, so might be nil:
    (attributes["details"]["breadcrumbs"] || []).each do |section|
      section['base_path'] = PublishingAPISection.base_path(@manual_slug, section['section_id'])
    end
    attributes
  end

  def add_base_path_to_manual(attributes)
    attributes["details"]["manual"] = {
      "base_path" => PublishingAPIManual.base_path(@manual_slug)
    }
    attributes
  end

  def incoming_section_is_valid
    unless @section.valid?
      @section.errors.full_messages.each {|message| self.errors[:base] << message }
    end
  end
end
