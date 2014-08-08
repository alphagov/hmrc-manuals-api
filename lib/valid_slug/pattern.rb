module ValidSlug
  # Lowercase, alphanumeric, words may be separated by dashes only, no leading
  # or trailing dashes.
  #
  # Trying to implement: https://insidegovuk.blog.gov.uk/url-standards-for-gov-uk/
  #
  # Doesn't prevent: multiple consecutive dashes.
  PATTERN = /\A[a-z\d][a-z\d-]*[a-z\d]\z/
end
