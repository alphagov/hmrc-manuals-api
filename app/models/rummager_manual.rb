class RummagerManual < RummagerBase
  def initialize(base_path, publishing_api_manual_hash)
    @base_path = base_path
    @publishing_api_manual = publishing_api_manual_hash
  end

  def id
    @base_path
  end

  def to_h
    {
      'title'             => @publishing_api_manual['title'],
      'description'       => @publishing_api_manual['description'],
      'link'              => @base_path,
      'indexable_content' => nil,
      'organisations'     => [GOVUK_HMRC_SLUG],
      'last_update'       => @publishing_api_manual['public_updated_at'],
      'format'            => PublishingAPIManual::FORMAT,
    }
  end
end
