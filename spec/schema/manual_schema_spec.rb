require 'rails_helper'

describe 'manual schema' do
  def get_validation_errors(manual, options = {})
    options = { validate_schema: true }.merge(options)
    JSON::Validator.fully_validate(MANUAL_SCHEMA, manual, options)
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
      get_validation_errors(MANUAL_SCHEMA, maximal_manual, strict: true)
    end

    it 'should be valid' do
      expect(errors).to eql([])
    end
  end
end
