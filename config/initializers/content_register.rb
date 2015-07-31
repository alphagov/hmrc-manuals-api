require 'gds_api/content_register'

HMRCManualsAPI.content_register = GdsApi::ContentRegister.new(Plek.current.find('content-register'))
