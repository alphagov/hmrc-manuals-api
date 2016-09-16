source 'https://rubygems.org'

gem 'rails', '4.2.7.1'
gem 'logstasher', '0.5.3'
gem 'unicorn', '4.8.3'
gem 'airbrake', '3.1.15'
gem 'json-schema', '2.5.1'
gem 'gds-sso', '9.3.0'
gem 'plek', '1.11.0'
gem 'gds-api-adapters', '35.0.1'
gem 'govspeak', '~> 3.3.0'
gem 'sidekiq', '3.4.2'
gem 'uuidtools', '2.1.5'
gem 'responders', '~> 2.0'

group :development do
  gem "foreman", "0.78.0"
end

group :development, :test do
  gem 'rspec-rails', '3.5.2'
  gem 'rspec-collection_matchers', '1.1.2'
  gem 'pry-byebug'
  gem 'shoulda-matchers', '~> 3.1'
  gem "govuk-lint"
end

group :test do
  gem 'simplecov', '0.8.2', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter_rspec', '1.0.0'
  gem 'webmock', '1.18.0'
  gem 'govuk-content-schema-test-helpers', '1.3.0'
end
