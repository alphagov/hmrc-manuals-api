class LinksBuilder
  HMRC_CONTENT_ID = "6667cce2-e809-4e21-ae09-cb0bdc1ddda3".freeze

  def initialize(content_id)
    @content_id = content_id
    @built_links = {}
  end

  def build_links
    begin
      @content_store_links = Services.publishing_api.get_links(@content_id)["links"].with_indifferent_access
    rescue GdsApi::HTTPNotFound
      @content_store_links = nil
    end
    set_organisation
    set_primary_organisation
    @built_links
  end

private

  def set_organisation
    @built_links["organisations"] = if @content_store_links && @content_store_links["organisations"].present?
                                      @content_store_links["organisations"]
                                    else
                                      [HMRC_CONTENT_ID]
                                    end
  end

  def set_primary_organisation
    @built_links["primary_publishing_organisation"] = [HMRC_CONTENT_ID]
  end
end
