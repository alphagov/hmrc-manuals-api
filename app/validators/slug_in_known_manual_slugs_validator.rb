class SlugInKnownManualSlugsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless KNOWN_MANUAL_SLUGS.include?(value)
      record.errors.add(attribute, "does not match any of the following valid slugs: #{KNOWN_MANUAL_SLUGS.join(' ')} ")
    end
  end
end
