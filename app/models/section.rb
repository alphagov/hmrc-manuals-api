require 'active_model'

class Section
  include ActiveModel::Validations

  attr_reader :section_attributes, :manual_slug, :section_id
  validates :section_attributes, conforms_to_json_schema: { schema: SECTION_SCHEMA }
  validate :publishing_api_section_is_valid

  def initialize(manual_slug, section_id, section_attributes)
    @manual_slug = manual_slug
    @section_id = section_id
    @section_attributes = section_attributes
  end

  def publishing_api_section
    @_publishing_api_section ||= PublishingAPISection.new(self)
  end

  def save!
    HMRCManualsAPI.publishing_api.put_content_item(
      PublishingAPISection.base_path(@manual_slug, @section_id),
      publishing_api_section.to_h
    )
  end

private
  def publishing_api_section_is_valid
    section = publishing_api_section
    unless section.valid?
      section.errors.each {|key, value| self.errors[key] << value }
    end
  end
end
