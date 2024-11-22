module PublishingApiHelper
  def publishing_api_validation_error
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}\/.*/).to_return(status: 422)
  end
end
