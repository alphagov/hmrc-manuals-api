class PublishingAPINotifier
  def initialize(document)
    @document = document
  end

  def notify
    content_item = put_content_item
    publish(content_item.version)
    content_item
  end

private
  def put_content_item
    Services.publishing_api.put_content(@document.content_id, @document.to_h)
  end

  def publish(version)
    Services.publishing_api.publish(
      @document.content_id,
      @document.update_type,
      previous_version: version
    )
  end
end
