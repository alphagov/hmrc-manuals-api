module ValidationHelpers
  def get_validation_errors(schema, data, options = {})
    options = { validate_schema: true }.merge(options)
    JSON::Validator.fully_validate(schema, data, options)
  end
end

RSpec.configuration.include ValidationHelpers
