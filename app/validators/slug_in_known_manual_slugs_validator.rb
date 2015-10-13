class SlugInKnownManualSlugsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless record.known_manual_slugs.include?(value)
      record.errors[attribute] << "does not match any of the following valid slugs: #{ record.known_manual_slugs.join(" ") }"
    end
  end
end
