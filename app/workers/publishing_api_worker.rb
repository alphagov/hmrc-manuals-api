class PublishingApiWorker < WorkerBase
  include Sidekiq::Worker

  def perform(document_json)
    puts "before json"
    document = JSON.parse(document_json)
    puts "in worker"
    puts document.inspect
    content_item = put_content_item(document)
    publish(document, content_item["version"])
    patch_links(document) if update_links
    puts content_item
  end

private

  def put_content_item(document)
    puts "1a"
    Services.publishing_api.put_content(document.content_id, document)
    puts "1b"
  end

  def patch_links(document)
    puts "2a"
    Services.publishing_api.patch_links(document.content_id, links: document.links)
    puts "2b"
  end

  def publish(document, version)
    puts "3a"
    Services.publishing_api.publish(
      document.content_id,
      nil, # this is update_type, which is being deprecated. We still need to pass it for now.
      previous_version: version,
    )
    puts "3b"
  end
end
