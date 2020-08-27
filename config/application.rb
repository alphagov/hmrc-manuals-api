require_relative "boot"

require "rails"

require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HMRCManualsAPI
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # We need to put this middleware back, after "rails-api" strips it out.
    # This middleware must be present, otherwise the "request_store" gem, which
    # is a dependency of "logstasher", falls over. It's not clear whether "request_store"
    # actually uses this middleware itself, but it references it in the railtie.
    config.middleware.insert_after(Rack::Runtime, Rack::MethodOverride)
  end
end
