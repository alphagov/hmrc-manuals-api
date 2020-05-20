require "govspeak/html_validator"
require "structured_data"

class NoDangerousHTMLInTextFieldsValidator < ActiveModel::EachValidator
  ALLOWED_IMAGE_HOSTS = [
    # URLs for the local environment
    URI.parse(Plek.new.website_root).host, # eg www.preview.alphagov.co.uk
    URI.parse(Plek.new.asset_root).host,   # eg assets-origin.preview.alphagov.co.uk

    # Hardcode production URLs so that content copied from production is valid
    "www.gov.uk",
    "assets.digital.cabinet-office.gov.uk",
    "assets.publishing.service.gov.uk",
  ].freeze

  def validate_each(record, _attribute, value)
    freetext_fields_with_paths = StructuredData.new(value).string_fields
    freetext_fields_with_paths.each do |field_with_path|
      next unless dangerous?(field_with_path[:value])

      record.errors[:base] << "'#{field_with_path[:path]}' contains disallowed HTML; " \
        "the following tags are allowed: #{allowed_html_tags.join(', ')} and " \
        "the following tag attributes are allowed: #{allowed_html_attributes.inspect} and " \
        "inline images are allowed if they are relative or hosted on these domains: #{ALLOWED_IMAGE_HOSTS.join(', ')}"
    end
  end

private

  def dangerous?(value)
    validator = Govspeak::HtmlValidator.new(value, allowed_image_hosts: ALLOWED_IMAGE_HOSTS)
    validator.invalid?
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
