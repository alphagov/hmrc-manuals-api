ARG ruby_version=3.1.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version

FROM $builder_image AS builder

WORKDIR /app
COPY Gemfile* .ruby-version /app/
# TODO: remove chmod workaround once https://www.github.com/mikel/mail/issues/1489 is fixed.
RUN bundle install && chmod -R o+r "${BUNDLE_PATH}"
COPY . /app


FROM $base_image

ENV GOVUK_APP_NAME=hmrc-manuals-api

WORKDIR /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/

CMD ["bundle", "exec", "puma"]
