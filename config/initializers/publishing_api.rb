require 'gds_api/publishing_api_v2'

HMRCManualsAPI.publishing_api = GdsApi::PublishingApiV2.new(
  Plek.new.find('publishing-api'),
  bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
)
