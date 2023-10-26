ARG ruby_version=3.2.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version

FROM $builder_image AS builder

WORKDIR $APP_HOME
COPY Gemfile* .ruby-version /app/
# TODO: remove chmod workaround once https://www.github.com/mikel/mail/issues/1489 is fixed.
RUN bundle install && chmod -R o+r "${BUNDLE_PATH}"
COPY . ./


FROM $base_image

ENV GOVUK_APP_NAME=hmrc-manuals-api

WORKDIR $APP_HOME
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder $APP_HOME ./

CMD ["puma"]
