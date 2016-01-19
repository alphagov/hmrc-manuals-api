class RummagerManual < RummagerBase

  def initialize(base_path, publishing_api_manual_hash)
    @base_path = base_path
    @publishing_api_manual = publishing_api_manual_hash
  end

  def id
    @base_path
  end

  def to_h
    data = {
      'title'              => @publishing_api_manual['title'],
      'description'        => @publishing_api_manual['description'],
      'link'               => id,
      'indexable_content'  => nil,
      'organisations'      => [GOVUK_HMRC_SLUG],
      'public_timestamp'   => @publishing_api_manual['public_updated_at'],
      'format'             => MANUAL_FORMAT,
      'latest_change_note' => latest_change_note,
    }

    data
  end

  def save!
    SendToRummagerWorker.perform_async(MANUAL_FORMAT, self.id, self.to_h)
  end

private
  def topics
    @publishing_api_manual['details'].fetch('tags', {}).fetch('topics', [])
  end

  def latest_change_note
    latest = @publishing_api_manual['details'].fetch('change_notes', []).first

    "#{latest['change_note']} in #{latest['title']}" if latest
  end
end
