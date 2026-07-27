require "gds_api/asset_manager"
require "gds_api/content_store"
require "gds_api/publishing_api"
require "gds_api/search"

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(
      Plek.find("publishing-api"),
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
      timeout: 10,
    )
  end

  def self.asset_manager
    if Rails.configuration.allow_asset_manager_requests
      @asset_manager ||= GdsApi::AssetManager.new(
        Plek.find("asset-manager"),
        bearer_token: ENV["ASSET_MANAGER_BEARER_TOKEN"] || "example",
        timeout: 60,
      )
    else
      Rails.logger.warn("Asset Manager requests are disabled in this environment")
    end
  end

  def self.search_api
    @search_api ||= GdsApi::Search.new(Plek.find("search-api"))
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.find("content-store"))
  end
end
