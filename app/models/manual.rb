require 'active_model'
require 'gds_api/content_store'

class Manual
  include ActiveModel::Validations

  attr_reader :manual_attributes, :slug
  validates :manual_attributes, conforms_to_json_schema: { schema: MANUAL_SCHEMA }

  def initialize(slug, manual_attributes)
    @slug = slug
    @manual_attributes = manual_attributes
  end

  def manual_base_path
    "/guidance/#{@slug}"
  end

  def save!
    api = GdsApi::ContentStore.new(Plek.current.find('content-store'))
    api.put_content_item(manual_base_path, ContentStoreManual.new(self).to_h)
  end
end
