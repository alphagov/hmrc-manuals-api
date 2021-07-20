require "active_model"

class Manual
  include ActiveModel::Validations

  attr_reader :manual_attributes

  validates :manual_attributes, conforms_to_json_schema: { schema: MANUAL_SCHEMA }

  def initialize(manual_attributes)
    @manual_attributes = manual_attributes
  end
end
