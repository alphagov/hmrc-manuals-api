class RummagerBase
  GOVUK_HMRC_SLUG = 'hm-revenue-customs'

  def strip_leading_slash(path)
    path.gsub(%r{^/}, '')
  end
end
