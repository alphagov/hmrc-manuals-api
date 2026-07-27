module PublishingApiHelper
  def stub_publishing_api_returns_error(status)
    stub_request(:any, /#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}\/.*/).to_return(status:)
  end
end
