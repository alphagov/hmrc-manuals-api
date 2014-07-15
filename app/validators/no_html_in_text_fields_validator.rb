require 'sanitize'
require 'structured_data'

class NoHtmlInTextFieldsValidator < ActiveModel::EachValidator
  HTML_WHITELIST_CONFIG = { # don't allow any HTML at all
    elements: [],
    attributes: {},
    add_attributes: {},
    protocols: {}
  }

  def validate_each(record, attribute, value)
    freetext_fields_with_paths = StructuredData.new(value).string_fields
    freetext_fields_with_paths.each do |field_with_path|
      if dangerous?(field_with_path[:value])
        record.errors[:base] << "'#{field_with_path[:path]}' contains HTML, which isn't allowed."
      end
    end
  end

private
  def dangerous?(value)
    value != Sanitize.fragment(value, HTML_WHITELIST_CONFIG)
  end
end
