require 'active_model'
require 'gds_api/publishing_api'

class Manual
  include ActiveModel::Validations

  attr_reader :manual_attributes, :slug

  validates :json_schema_validation_errors, no_errors: true
  # Only try to create and validate a PublishingApiManual when we are sure this
  # Manual object is valid to avoid unhelpful NoMethodErrors from an incomplete
  # document
  validate :publishing_api_manual_is_valid, if: -> { json_schema_validation_errors.empty? }

  def initialize(slug, manual_attributes)
    @slug = slug
    @manual_attributes = manual_attributes
  end

  def publishing_api_manual
    PublishingApiManual.new(self)
  end

  def save!
    api = GdsApi::PublishingApi.new(Plek.current.find('publishing-api'))
    api.put_content_item(PublishingApiManual.base_path(@slug),
                         publishing_api_manual.to_h)
  end

  def json_schema_validation_errors
    JSON::Validator.fully_validate(MANUAL_SCHEMA, manual_attributes, validate_schema: true)
  end

private
  def publishing_api_manual_is_valid
    manual = publishing_api_manual
    unless manual.valid?
      manual.errors.each {|key, value| self.errors[key] << value }
    end
  end
end
