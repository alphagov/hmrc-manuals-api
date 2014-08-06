require 'active_model'
require 'struct_with_rendered_markdown'

class PublishingAPIManual
  include ActiveModel::Validations

  validates :to_h, no_dangerous_html_in_text_fields: true

  def initialize(manual)
    @slug = manual.slug
    @manual_attributes = manual.manual_attributes
  end

  def to_h
    enriched_data = @manual_attributes.clone.merge({
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
    Plek.current.find('www') + PublishingAPIManual.base_path(@slug)
  end

  def self.base_path(manual_slug)
    "/guidance/#{manual_slug}"
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
end
