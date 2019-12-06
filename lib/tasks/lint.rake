desc "Run rubocop with similar params to CI"
task lint: :environment do
  sh "bundle exec rubocop --format clang app spec lib"
end
