require 'gds_api/publishing_api'

HMRCManualsAPI.publishing_api = GdsApi::PublishingApi.new(Plek.current.find('publishing-api'))
