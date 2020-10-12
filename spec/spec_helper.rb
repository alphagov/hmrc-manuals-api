require "simplecov"
SimpleCov.start "rails"

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/example_status.txt"
end
