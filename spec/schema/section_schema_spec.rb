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

  describe 'validating section ID in details' do
    let(:json_path) { '#/details/section_id' }
    let(:section) { maximal_section }
    let(:errors) do
      section["details"]["section_id"] = value
      get_validation_errors(SECTION_SCHEMA, section)
    end

    it_behaves_like "it validates as a section ID"
  end

  describe 'validating section ID in breadcrumbs' do
    let(:json_path) { '#/details/breadcrumbs/0/section_id' }
    let(:section) { maximal_section }
    let(:errors) do
      section["details"]["breadcrumbs"][0]["section_id"] = value
      get_validation_errors(SECTION_SCHEMA, section)
    end

    it_behaves_like "it validates as a section ID"
  end

  describe 'validating section IDs in child_section_groups' do
    let(:json_path) { '#/details/child_section_groups/0/child_sections/0/section_id' }
    let(:section) { maximal_section }
    let(:errors) do
      section["details"]["child_section_groups"][0]["child_sections"][0]["section_id"] = value
      get_validation_errors(SECTION_SCHEMA, section)
    end

    it_behaves_like "it validates as a section ID"
  end
end
