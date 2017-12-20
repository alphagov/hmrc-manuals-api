source 'https://rubygems.org'

gem 'rails', '5.1.4'
gem 'logstasher', '1.2.2'
gem 'unicorn', '5.3.1'
gem 'json-schema', '2.8.0'
gem 'gds-sso', '~> 13.2.1'
gem 'plek', '2.0.0'
gem 'gds-api-adapters', '~> 50.6.0'
gem 'govspeak', '~> 5.2.2'
gem 'sidekiq', '3.4.2'
gem 'uuidtools', '2.1.5'
gem 'responders', '~> 2.0'
gem 'govuk_app_config', '~> 0.2.0'

group :development do
  gem "foreman", "0.84.0"
  gem 'listen'
end

group :development, :test do
  gem 'rspec-rails', '3.7.2'
  gem 'rspec-collection_matchers', '1.1.3'
  gem 'pry-byebug'
  gem 'shoulda-matchers', '~> 3.1'
  gem "govuk-lint"
end

group :test do
  gem 'simplecov', '0.15.1', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter_rspec', '1.0.0'
  gem 'webmock', '~> 3.1.1'
  gem 'govuk-content-schema-test-helpers', '1.6.0'
end
