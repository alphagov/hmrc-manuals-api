ARG base_image=ghcr.io/alphagov/govuk-ruby-base:2.7.6
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:2.7.6

FROM $builder_image AS builder

RUN mkdir /app

WORKDIR /app
COPY Gemfile* .ruby-version /app/

RUN BUNDLE_WITHOUT='development test webkit' bundle install

COPY . /app

FROM $base_image

ENV GOVUK_APP_NAME=hmrc-manuals-api

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/

WORKDIR /app

CMD bundle exec puma
