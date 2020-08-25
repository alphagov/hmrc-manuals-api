require "gds_api/publishing_api"
require "gds_api/search"
require "gds_api/content_store"

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(
      Plek.new.find("publishing-api"),
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end

  def self.search_api
    @search_api ||= GdsApi::Search.new(Plek.current.find("search"))
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.current.find("content-store"))
  end
end
