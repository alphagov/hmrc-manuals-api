require "simplecov"
require "simplecov-rcov"
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start "rails"

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/example_status.txt"
end
