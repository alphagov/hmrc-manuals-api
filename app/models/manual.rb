require 'active_model'
require 'gds_api/content_store'

class Manual
  include ActiveModel::Validations

  attr_reader :manual_attributes
  validates :manual_attributes, conforms_to_json_schema: { schema: MANUAL_SCHEMA }

  def initialize(slug, manual_attributes)
    @slug = slug
    @manual_attributes = manual_attributes
  end

  def manual_base_path
    "/guidance/#{@slug}"
  end

  def section_base_path(section_id)
    File.join(manual_base_path, section_id)
  end

  def data_for_content_store
    enriched_data = @manual_attributes.clone.merge({
      base_path: manual_base_path,
      format: 'hmrc-manual',
      publishing_app: 'hmrc-manuals-api',
      rendering_app: 'manuals-frontend',
      routes: [{ path: manual_base_path, type: :exact }]
      })
    add_base_path_to_child_section_groups(enriched_data)
  end

  def add_base_path_to_child_section_groups(attributes)
    attributes["details"]["child_section_groups"].each do |section_group|
      section_group["child_sections"].each do |section|
        section['base_path'] = section_base_path(section['section_id'])
      end
    end
    attributes
  end

  def save!
    api = GdsApi::ContentStore.new(Plek.current.find('content-store'))
    api.put_content_item(manual_base_path, data_for_content_store)
  end
end
