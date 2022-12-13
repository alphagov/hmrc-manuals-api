source "https://rubygems.org"

gem "rails", "7.0.4"

gem "gds-api-adapters"
gem "gds-sso"
gem "govspeak"
gem "govuk_app_config"
gem "json-schema"
gem "mail", "~> 2.7.1"  # TODO: remove once https://github.com/mikel/mail/issues/1489 is fixed.
gem "plek"
gem "responders"
gem "uuidtools"

group :development do
  gem "listen"
end

group :development, :test do
  gem "pry-byebug"
  gem "rspec-collection_matchers"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "shoulda-matchers"
end

group :test do
  gem "ci_reporter_rspec"
  gem "govuk_schemas"
  gem "simplecov", require: false
  gem "webmock"
end
