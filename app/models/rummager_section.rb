class RummagerSection < RummagerBase
  def initialize(publishing_api_section_hash)
    @publishing_api_section = publishing_api_section_hash
  end

  def id
    # The id and link are the path without the leading slash
    strip_leading_slash(@publishing_api_section['base_path'])
  end

  def section_id
    @publishing_api_section['details']['section_id']
  end

  def title
    "HMRC Manuals: #{section_id} - #{@publishing_api_section['title']}"
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
      'last_update'             => @publishing_api_section['public_updated_at'],
      'hmrc_manual_section_id'  => section_id,
      'manual'                  => strip_leading_slash(@publishing_api_section['details']['manual']['base_path']),
    }
  end
end
