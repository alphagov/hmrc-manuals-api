redis_config = {
  host: ENV["REDIS_HOST"] || "127.0.0.1",
  port: ENV["REDIS_PORT"] || 6379,
  namespace: "hmrc-manuals-api",
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.error_handlers << lambda do |exception, context|
     Airbrake.notify(exception, parameters: context)
   end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
