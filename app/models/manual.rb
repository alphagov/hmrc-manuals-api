require 'active_model'

class Manual
  include ActiveModel::Validations

  attr_reader :manual_attributes, :slug
  validates :manual_attributes, conforms_to_json_schema: { schema: MANUAL_SCHEMA }
  validate :publishing_api_manual_is_valid

  def initialize(slug, manual_attributes)
    @slug = slug
    @manual_attributes = manual_attributes
  end

  def publishing_api_manual
    @_publishing_api_manual ||= PublishingAPIManual.new(self)
  end

  def save!
    HMRCManualsAPI.publishing_api.put_content_item(
      PublishingAPIManual.base_path(@slug),
      publishing_api_manual.to_h
    )
  end

private
  def publishing_api_manual_is_valid
    manual = publishing_api_manual
    unless manual.valid?
      manual.errors.each {|key, value| self.errors[key] << value }
    end
  end
end
