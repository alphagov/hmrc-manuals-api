require 'gds_api/rummager'

HMRCManualsAPI.rummager = GdsApi::Rummager.new(Plek.current.find('search'))
