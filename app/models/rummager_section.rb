class RummagerSection < RummagerBase
  def initialize(base_path, publishing_api_section_hash, content_id)
    @base_path = base_path
    @publishing_api_section = publishing_api_section_hash
    @content_id = content_id
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
      'content_id' => @content_id,
      'content_store_document_type' => SECTION_DOCUMENT_TYPE,
      'description' => @publishing_api_section['description'],
      'format' => SECTION_SCHEMA_NAME,
      'hmrc_manual_section_id' => section_id,
      'indexable_content' => body_without_html,
      'link' => id,
      'manual' => @publishing_api_section['details']['manual']['base_path'],
      'public_timestamp' => @publishing_api_section['public_updated_at'],
      'publishing_app' => 'hmrc-manuals-api',
      'rendering_app' => 'manuals-frontend',
      'title' => title,
    }
  end

  def save!
    SendToRummagerWorker.perform_async(SECTION_DOCUMENT_TYPE, self.id, self.to_h)
  end

  def self.search_query(manual_path, start = 0, count = 1000)
    {
      'filter_format' => SECTION_SCHEMA_NAME,
      'filter_organisations' => GOVUK_HMRC_SLUG,
      'filter_manual' => manual_path,
      'count' => count,
      'start' => start,
    }
  end
end
