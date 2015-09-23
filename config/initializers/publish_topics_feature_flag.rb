if Rails.env.production?
  HMRCManualsAPI::Application.config.publish_topics = ENV["PUBLISH_TOPICS"].present?
else
  HMRCManualsAPI::Application.config.publish_topics = true
end
