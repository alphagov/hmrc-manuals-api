class RummagerManual < RummagerBase
  def initialize(publishing_api_manual_hash)
    @publishing_api_manual = publishing_api_manual_hash
  end

  def id
    # The id and link are the path without the leading slash
    strip_leading_slash(@publishing_api_manual['base_path'])
  end

  def to_h
    {
      'title'             => @publishing_api_manual['title'],
      'description'       => @publishing_api_manual['description'],
      'link'              => id,
      'indexable_content' => nil,
      'organisations'     => [GOVUK_HMRC_SLUG],
      'last_update'       => @publishing_api_manual['public_updated_at'],
    }
  end
end
