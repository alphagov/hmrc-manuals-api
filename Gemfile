source 'https://rubygems.org'

gem 'rails', '4.1.4'
gem 'rails-api', '0.2.1'
gem 'logstasher', '0.5.3'
gem 'unicorn', '4.8.3'
gem 'airbrake', '3.1.15'
gem 'json-schema', '2.2.3'
gem 'gds-sso', '9.3.0'
gem 'plek', '1.8.1'
if ENV['api_dev']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '12.5.0'
end
gem 'govspeak', '1.6.2'

group :development, :test do
  gem 'rspec-rails', '3.0.1'
  gem 'simplecov', '0.8.2', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter', '2.0.0.alpha2'
  gem 'ci_reporter_rspec', '0.0.2'
  gem 'webmock', '1.18.0'
end
