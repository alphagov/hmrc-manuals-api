class LinksBuilder
  def initialize(content_id)
    @content_id = content_id
    @built_links = {}
  end

  def build_links
    @content_store_links = Services.publishing_api
      .get_links(@content_id)
      .try(:links)
      .to_h.with_indifferent_access
    set_organistion
    @built_links
  end

private
  def set_organistion
    if @content_store_links["organisations"].present?
      @built_links["organisations"] = @content_store_links["organisations"]
    else
      # Use HMRC content ID to set organisation
      @built_links["organisations"] = ["6667cce2-e809-4e21-ae09-cb0bdc1ddda3"]
    end
  end
end
