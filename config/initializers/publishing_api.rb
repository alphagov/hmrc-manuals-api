require 'gds_api/publishing_api_v2'

HMRCManualsAPI.publishing_api = GdsApi::PublishingApiV2.new(Plek.current.find('publishing-api'))
