class SendToRummagerWorker
  include Sidekiq::Worker

  def perform(document_type, id, attributes)
    Services.rummager.add_document(document_type, id, attributes)
  end
end
