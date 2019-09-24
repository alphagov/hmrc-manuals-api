require "active_model"

class Section
  include ActiveModel::Validations

  attr_reader :section_attributes
  validates :section_attributes, conforms_to_json_schema: { schema: SECTION_SCHEMA }

  def initialize(section_attributes)
    @section_attributes = section_attributes
  end
end
