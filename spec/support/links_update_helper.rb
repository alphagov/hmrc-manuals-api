module LinksUpdateHelper
  def stub_publishing_api_get_links(content_id, body: { links: {} })
    stub_request(:get, Plek.new.find("publishing-api") + "/v2/links/#{content_id}")
      .to_return(body: body.to_json)
  end

  def stub_put_default_organisation(content_id)
    stub_publishing_api_patch_links(
      content_id,
      { links: { organisations: ["6667cce2-e809-4e21-ae09-cb0bdc1ddda3"],
        primary_publishing_organisation: ["6667cce2-e809-4e21-ae09-cb0bdc1ddda3"] } }.to_json,
    )
  end
end
