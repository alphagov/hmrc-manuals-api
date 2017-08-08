class InContentStoreValidator < ActiveModel::Validator
  attr_reader :schema_name, :content_store
  def initialize(options = {})
    super
    raise "Must provide schema_name and content_store options to the validator" unless options[:schema_name] && options[:content_store]
    raise 'Can\'t provide "gone" as a schema_name to the validator' if options[:schema_name] == 'gone'
    @schema_name = options[:schema_name]
    @content_store = options[:content_store]
  end

  def validate(record)
    content_item = fetch_content_item(record)
    if content_item["schema_name"] != schema_name
      record.errors.add(:base, wrong_schema_name_message(record, content_item))
    end
  rescue GdsApi::HTTPNotFound
    record.errors.add(:base, missing_message(record, content_item))
  rescue GdsApi::HTTPGone
    record.errors.add(:base, gone_message(record, content_item))
  end

private

  def fetch_content_item(record)
    content_store.content_item(record.base_path)
  end

  def missing_message(_record, _content_item)
    'Is not a manual in the content store'
  end

  def gone_message(_record, _content_item)
    'Exists in the content store, but is already "gone"'
  end

  def wrong_schema_name_message(_record, content_item)
    %{Exists in the content store, but is not a "#{schema_name}" schema (it's a "#{content_item['schema_name']}" schema)"}
  end
end
