class SendToRummagerWorker
  include Sidekiq::Worker

  def perform(format, id, attributes)
    HMRCManualsAPI.rummager.add_document(format, id, attributes)
  end
end
