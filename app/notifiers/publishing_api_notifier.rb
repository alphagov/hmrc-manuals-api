class PublishingAPINotifier
  def initialize(document)
    @document = document
  end

  def notify(update_links: true)
    content_item = put_content_item
    publish(content_item["version"])
    patch_links if update_links
    content_item
  end

private

  def put_content_item
    Services.publishing_api.put_content(@document.content_id, @document.to_h)
  end

  def patch_links
    Services.publishing_api.patch_links(@document.content_id, links: @document.links)
  end

  def publish(version)
    Services.publishing_api.publish(
      @document.content_id,
      @document.update_type,
      previous_version: version
    )
  end
end
