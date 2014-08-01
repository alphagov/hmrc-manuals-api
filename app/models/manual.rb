require 'active_model'
require 'gds_api/content_store'

class Manual
  include ActiveModel::Validations

  attr_reader :manual_attributes, :slug
  validates :manual_attributes, conforms_to_json_schema: { schema: MANUAL_SCHEMA }
  validate :content_store_manual_is_valid

  def initialize(slug, manual_attributes)
    @slug = slug
    @manual_attributes = manual_attributes
  end

  def content_store_manual
    ContentStoreManual.new(self)
  end

  def save!
    api = GdsApi::ContentStore.new(Plek.current.find('content-store'))
    api.put_content_item(ContentStoreManual.base_path(@slug),
                         content_store_manual.to_h)
  end

private
  def content_store_manual_is_valid
    manual = content_store_manual
    unless manual.valid?
      manual.errors.each {|key, value| self.errors[key] << value }
    end
  end
end
