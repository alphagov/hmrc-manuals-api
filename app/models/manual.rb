require 'active_model'
require 'gds_api/content_store'

class Manual
  include ActiveModel::Validations

  attr_reader :manual_attributes
  validates :manual_attributes, conforms_to_json_schema: { schema: MANUAL_SCHEMA }

  def initialize(slug, manual_attributes)
    @slug = slug
    @manual_attributes = manual_attributes
  end

  def base_path
    "/guidance/#{@slug}"
  end

  def data_for_content_store
    @manual_attributes.clone.merge({
      base_path: base_path,
      format: 'hmrc-manual',
      publishing_app: 'hmrc-manuals-api',
      rendering_app: 'manuals-frontend',
      routes: [{ path: base_path, type: :exact }]
      })
  end

  def save!
    api = GdsApi::ContentStore.new(Plek.current.find('content-store'))
    api.put_content_item(base_path, data_for_content_store)
  end
end
