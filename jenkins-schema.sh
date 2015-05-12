#!/bin/bash

export REPO_NAME="alphagov/govuk-content-schemas"
export CONTEXT_MESSAGE="Verify hmrc-manuals-api against content schemas"

exec ./jenkins.sh
