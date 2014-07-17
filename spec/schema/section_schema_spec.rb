require 'rails_helper'

describe 'section schema' do
  context 'a minimal document' do
    let(:errors) { get_validation_errors(SECTION_SCHEMA, valid_section) }

    it 'should be valid' do
      expect(errors).to eql([])
    end
  end

  context 'a maximal document' do
    let(:errors) do
      # Perform strict validation so that we know all keys in the example are
      # allowed, and that we have included every key that can be included
      # (although it will accept empty arrays where an array is expected).
      get_validation_errors(SECTION_SCHEMA, maximal_section, strict: true)
    end

    it 'should be valid' do
      expect(errors).to eql([])
    end
  end
end
