# this middleware isn't used in token authentication
Rails.application.config.middleware.delete OmniAuth::Builder
