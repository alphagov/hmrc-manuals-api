class RummagerSection < RummagerBase
  def initialize(base_path, publishing_api_section_hash)
    @base_path = base_path
    @publishing_api_section = publishing_api_section_hash
  end

  def id
    @base_path
  end

  def section_id
    @publishing_api_section['details']['section_id']
  end

  def title
    "#{section_id} - #{@publishing_api_section['title']}"
  end

  def body_without_html
    Govspeak::Document.new(@publishing_api_section['details']['body']).to_text
  end

  def to_h
    {
      'title'                   => title,
      'description'             => @publishing_api_section['description'],
      'link'                    => id,
      'indexable_content'       => body_without_html,
      'organisations'           => [GOVUK_HMRC_SLUG],
      'public_timestamp'        => @publishing_api_section['public_updated_at'],
      'hmrc_manual_section_id'  => section_id,
      'manual'                  => strip_leading_slash(@publishing_api_section['details']['manual']['base_path']),
      'format'                  => SECTION_FORMAT,
    }
  end

  def save!
    SendToRummagerWorker.perform_async(SECTION_FORMAT, self.id, self.to_h)
  end
end
