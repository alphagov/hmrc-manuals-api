require "gds_api/publishing_api"
require "gds_api/search"
require "gds_api/content_store"

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(
      Plek.find("publishing-api"),
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
      timeout: 10,
    )
  end

  def self.search_api
    @search_api ||= GdsApi::Search.new(Plek.find("search-api"))
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.find("content-store"))
  end
end
