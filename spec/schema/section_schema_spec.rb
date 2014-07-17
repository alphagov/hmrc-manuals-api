require 'rails_helper'

describe 'section schema' do
  def get_validation_errors(section, options = {})
    options = { validate_schema: true }.merge(options)
    JSON::Validator.fully_validate(SECTION_SCHEMA, section, options)
  end

  context 'a minimal document' do
    let(:errors) { get_validation_errors(valid_section) }

    it 'should be valid' do
      expect(errors).to eql([])
    end
  end

  context 'a maximal document' do
    let(:errors) do
      # Perform strict validation so that we know all keys in the example are
      # allowed, and that we have included every key that can be included
      # (although it will accept empty arrays where an array is expected).
      get_validation_errors(maximal_section, strict: true)
    end

    it 'should be valid' do
      expect(errors).to eql([])
    end
  end
end
