module ValidSlug
  # Lowercase, alphanumeric, words may be separated by dashes only, no leading
  # or trailing dashes, or multiple consecutive dashes.
  #
  # Trying to implement: https://insidegovuk.blog.gov.uk/url-standards-for-gov-uk/
  PATTERN = /\A[a-z\d]+(?:-[a-z\d]+)*\z/.freeze
end
