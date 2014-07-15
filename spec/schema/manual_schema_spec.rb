require 'rails_helper'

describe 'manual schema' do
  def get_validation_errors(manual, options = {})
    options = { validate_schema: true }.merge(options)

    # Work around an inconsistency in JSON::Validator where some keys in the data
    # have to be strings, even though it appears to support symbol keys. Do this
    # by converting the hash to a JSON string and letting JSON::Validator parse
    # it back.
    #
    # This isn't a problem in the controller, because that always receives a JSON
    # string.
    #
    # See: https://github.com/hoxworth/json-schema/issues/104
    JSON::Validator.fully_validate(MANUAL_SCHEMA, manual.to_json, options)
  end

  context 'a minimal document' do
    let(:errors) { get_validation_errors(valid_manual) }

    it 'should be valid' do
      expect(errors).to eql([])
    end
  end

  context 'a maximal document' do
    let(:errors) do
      # Perform strict validation so that we know all keys in the example are
      # allowed, and that we have included every key that can be included
      # (although it will accept empty arrays where an array is expected).
      get_validation_errors(maximal_manual, strict: true)
    end

    it 'should be valid' do
      expect(errors).to eql([])
    end
  end
end
