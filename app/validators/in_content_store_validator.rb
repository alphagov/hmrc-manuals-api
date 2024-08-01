class InContentStoreValidator < ActiveModel::Validator
  attr_reader :schema_names, :content_store

  def initialize(options = {})
    super
    raise "Must provide schema_names and content_store options to the validator" unless options[:schema_names] && options[:content_store]
    raise 'Can\'t provide "gone" as schema_names to the validator' if options[:schema_names].include?("gone")

    @schema_names = options[:schema_names]
    @content_store = options[:content_store]
  end

  def validate(record)
    content_item = fetch_content_item(record)
    unless schema_names.include?(content_item["schema_name"])
      record.errors.add(:base, wrong_schema_names_message(record, content_item))
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
    "Is not a manual in the content store"
  end

  def gone_message(_record, _content_item)
    'Exists in the content store, but is already "gone"'
  end

  def wrong_schema_names_message(_record, content_item)
    %{Exists in the content store, but is not a "#{schema_names.join(',')}" schema (it's a "#{content_item['schema_name']}" schema)}
  end
end
