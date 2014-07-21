module ValidationHelpers
  def get_validation_errors(schema, data, options = {})
    options = { validate_schema: true }.merge(options)
    # Work around json-schema not consistently handling symbol keys in data.
    JSON::Validator.fully_validate(schema, data.deep_stringify_keys, options)
  end
end

RSpec.configuration.include ValidationHelpers
