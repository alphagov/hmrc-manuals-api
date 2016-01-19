class ConformsToJsonSchemaValidator < ActiveModel::EachValidator
  def initialize(options = {})
    super
    raise "Provide a schema to the validator (schema: <SCHEMA>)" unless options[:schema]
    @schema = options[:schema]
  end

  def validate_each(record, _attribute, value)
    errors = JSON::Validator.fully_validate(@schema, value, validate_schema: true)
    errors.each {|e| record.errors[:base] << e }
  end
end
