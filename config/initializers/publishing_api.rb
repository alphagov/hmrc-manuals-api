require 'gds_api/publishing_api'

HmrcManualsApi.publishing_api = GdsApi::PublishingApi.new(Plek.current.find('publishing-api'))
