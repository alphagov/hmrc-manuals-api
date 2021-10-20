class PublishingAPINotifier
  def initialize(document)
    @document = document
  end

  def notify(update_links: true)
    PublishingApiWorker.perform_async(@document)
  end
end
