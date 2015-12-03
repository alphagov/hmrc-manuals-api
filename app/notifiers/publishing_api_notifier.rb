class PublishingAPINotifier
  def initialize(document)
    @document = document
  end

  def notify
    content_item = put_content_item
    publish(previous_version: content_item.version)
    put_links if @document.send_topic_links?
    content_item
  end

private
  def put_content_item
    HMRCManualsAPI.publishing_api.put_content(@document.content_id, @document.to_h)
  end

  def publish(options)
    HMRCManualsAPI.publishing_api.publish(@document.content_id, @document.update_type, options)
  end

  def put_links
    HMRCManualsAPI.publishing_api.put_links(@document.content_id, @document.topic_links) if @document.send_topic_links?
  end
end
