require 'active_model'
require 'gds_api/content_store'

class Section
  include ActiveModel::Validations

  attr_reader :section_attributes, :manual_slug, :section_id
  validates :section_attributes, conforms_to_json_schema: { schema: SECTION_SCHEMA }
  validate :content_store_section_is_valid

  def initialize(manual_slug, section_id, section_attributes)
    @manual_slug = manual_slug
    @section_id = section_id
    @section_attributes = section_attributes
  end

  def content_store_section
    ContentStoreSection.new(self)
  end

  def save!
    api = GdsApi::ContentStore.new(Plek.current.find('content-store'))
    api.put_content_item(ContentStoreSection.base_path(@manual_slug, @section_id),
                         content_store_section.to_h)
  end

private
  def content_store_section_is_valid
    section = content_store_section
    unless section.valid?
      section.errors.each {|key, value| self.errors[key] << value }
    end
  end
end
