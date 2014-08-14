require 'govspeak/html_validator'
require 'structured_data'
require 'nokogiri'

class NoDangerousHTMLInTextFieldsValidator < ActiveModel::EachValidator
  ALLOWED_IMAGE_HOSTS = ['www.gov.uk', 'assets.digital.cabinet-office.gov.uk']

  def validate_each(record, attribute, value)
    freetext_fields_with_paths = StructuredData.new(value).string_fields
    freetext_fields_with_paths.each do |field_with_path|
      if dangerous?(field_with_path[:value])
        record.errors[:base] << "'#{field_with_path[:path]}' contains disallowed HTML; " +
          "the following tags are allowed: #{allowed_html_tags.join(", ")} and " +
          "the following tag attributes are allowed: #{allowed_html_attributes.inspect}"
      end
      if disallowed_images?(field_with_path[:value])
        record.errors[:base] << "Images can only be used if hosted on #{ALLOWED_IMAGE_HOSTS.first} or #{ALLOWED_IMAGE_HOSTS.last}."
      end
    end
  end

private
  def dangerous?(value)
    Govspeak::HtmlValidator.new(value).invalid?
  end

  def disallowed_images?(value)
    html = Govspeak::Document.new(value).to_html
    Nokogiri::HTML.parse(html).css('img').any? do |img|
      uri = URI.parse(img.attributes['src'])
      next if uri.relative?
      ALLOWED_IMAGE_HOSTS.exclude?(uri.host)
    end
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
