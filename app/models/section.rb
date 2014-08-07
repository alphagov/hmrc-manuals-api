require 'active_model'
require 'gds_api/publishing_api'

class Section
  include ActiveModel::Validations

  attr_reader :section_attributes, :manual_slug, :section_id
  validates :json_schema_validation_errors, no_errors: true
  validate :publishing_api_section_is_valid, if: -> { json_schema_validation_errors.empty? }

  def initialize(manual_slug, section_id, section_attributes)
    @manual_slug = manual_slug
    @section_id = section_id
    @section_attributes = section_attributes
  end

  def publishing_api_section
    PublishingApiSection.new(self)
  end

  def save!
    api = GdsApi::PublishingApi.new(Plek.current.find('publishing-api'))
    api.put_content_item(PublishingApiSection.base_path(@manual_slug, @section_id),
                         publishing_api_section.to_h)
  end

  def json_schema_validation_errors
    JSON::Validator.fully_validate(SECTION_SCHEMA, section_attributes, validate_schema: true)
  end

private
  def publishing_api_section_is_valid
    section = publishing_api_section
    unless section.valid?
      section.errors.each {|key, value| self.errors[key] << value }
    end
  end
end
