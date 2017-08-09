class RummagerManual < RummagerBase
  def initialize(base_path, publishing_api_manual_hash, content_id)
    @base_path = base_path
    @publishing_api_manual = publishing_api_manual_hash
    @content_id = content_id
  end

  def id
    @base_path
  end

  def to_h
    {
      'content_id' => @content_id,
      'content_store_document_type' => MANUAL_DOCUMENT_TYPE,
      'description' => @publishing_api_manual['description'],
      'format' => MANUAL_SCHEMA_NAME,
      'indexable_content' => nil,
      'latest_change_note' => latest_change_note,
      'link' => id,
      'public_timestamp' => @publishing_api_manual['public_updated_at'],
      'publishing_app' => 'hmrc-manuals-api',
      'rendering_app' => 'manuals-frontend',
      'title' => @publishing_api_manual['title'],
    }
  end

  def save!
    SendToRummagerWorker.perform_async(MANUAL_DOCUMENT_TYPE, self.id, self.to_h)
  end

private

  def latest_change_note
    latest = @publishing_api_manual['details'].fetch('change_notes', []).first

    "#{latest['change_note']} in #{latest['title']}" if latest
  end
end
