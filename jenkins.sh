#!/bin/bash -x

set -e

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

export RAILS_ENV=test
git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake ci:setup:rspec default --trace
