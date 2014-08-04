require 'govspeak/html_validator'
require 'structured_data'

class NoDangerousHTMLInTextFieldsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    freetext_fields_with_paths = StructuredData.new(value).string_fields
    freetext_fields_with_paths.each do |field_with_path|
      if dangerous?(field_with_path[:value])
        record.errors[:base] << "'#{field_with_path[:path]}' contains disallowed HTML; " +
          "the following tags are allowed: #{allowed_html_tags.join(", ")} and " +
          "the following tag attributes are allowed: #{allowed_html_attributes.inspect}"
      end
    end
  end

private
  def dangerous?(value)
    !Govspeak::HtmlValidator.new(value).valid?
  end

  def allowed_html_tags
    sanitiser_config[:elements].sort
  end

  def allowed_html_attributes
    sanitiser_config[:attributes]
  end

  def sanitiser_config
    Govspeak::HtmlSanitizer.new(nil).sanitize_config
  end
end
