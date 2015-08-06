class RummagerManual < RummagerBase

  def initialize(base_path, publishing_api_manual_hash)
    @base_path = base_path
    @publishing_api_manual = publishing_api_manual_hash
  end

  def id
    # The id and link are the path without the leading slash
    strip_leading_slash(@base_path)
  end

  def to_h
    {
      'title'             => @publishing_api_manual['title'],
      'description'       => @publishing_api_manual['description'],
      'link'              => id,
      'indexable_content' => nil,
      'organisations'     => [GOVUK_HMRC_SLUG],
      'last_update'       => @publishing_api_manual['public_updated_at'],
      'format'            => MANUAL_FORMAT,
    }
  end

  def save!
    SendToRummagerWorker.perform_async(MANUAL_FORMAT, self.id, self.to_h)
  end
end
