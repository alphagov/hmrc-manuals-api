require 'rails_helper'

describe 'JSON examples for requests' do
  let(:requests_dir) { File.join(Rails.root, 'json_examples', 'requests') }

  describe 'Employment Income Manual' do
    let(:manual_filepath) { File.join(requests_dir, 'employment-income-manual.json') }

    it 'should be valid JSON' do
      expect { JSON.parse(File.read(manual_filepath)) }.not_to raise_error
    end

    it 'should be valid against the manual schema' do
      manual_example = JSON.parse(File.read(manual_filepath))
      errors = get_validation_errors(MANUAL_SCHEMA, manual_example)
      expect(errors).to eql([])
    end
  end

  describe 'Employment Income Manual sections' do
    # Validate all example sections in this directory
    let(:section_filepaths) { Dir[File.join(requests_dir, 'employment-income-manual', '**', '*.json')] }

    specify 'data under test is present' do
      expect(section_filepaths).not_to be_empty
    end

    specify 'all section examples should be valid JSON' do
      section_filepaths.each do |filename|
        expect { JSON.parse(File.read(filename)) }.not_to raise_error
      end
    end

    specify 'all section examples should be valid against the section schema' do
      section_filepaths.each do |filename|
        section_example = JSON.parse(File.read(filename))
        errors = get_validation_errors(SECTION_SCHEMA, section_example)
        expect(errors).to eql([])
      end
    end
  end
end
