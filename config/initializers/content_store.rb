require 'gds_api/content_store'

HMRCManualsAPI.content_store = GdsApi::ContentStore.new(Plek.current.find('content-store'))
