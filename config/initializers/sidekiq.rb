redis_config = {
  host: ENV["REDIS_HOST"] || "127.0.0.1",
  port: ENV["REDIS_PORT"] || 6379,
  namespace: "hmrc-manuals-api",
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
