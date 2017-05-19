# this middleware isn't used in token authentication
Rails.application.config.middleware.delete OmniAuth::Builder

GDS::SSO.config do |config|
  config.user_model   = 'User'
  config.oauth_id     = Rails.application.secrets["gds-sso"][:oauth_id]
  config.oauth_secret = Rails.application.secrets["gds-sso"][:oauth_secret]
  config.oauth_root_url = Plek.current.find("signon")
end
