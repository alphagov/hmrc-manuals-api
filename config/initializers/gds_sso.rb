# this middleware isn't used in token authentication
Rails.application.config.middleware.delete OmniAuth::Builder

GDS::SSO.config do |config|
  # Treat every request as an API call; disable the browser sign-in flow
  config.api_only = true
end
