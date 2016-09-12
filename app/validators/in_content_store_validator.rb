class InContentStoreValidator < ActiveModel::Validator
  attr_reader :format, :content_store
  def initialize(options = {})
    super
    raise "Must provide format and content_store options to the validator" unless options[:format] && options[:content_store]
    raise 'Can\'t provide "gone" as a format to the validator' if options[:format] == 'gone'
    @format = options[:format]
    @content_store = options[:content_store]
  end

  def validate(record)
    content_item = fetch_content_item(record)
    if content_item.format != format
      record.errors.add(:base, wrong_format_message(record, content_item))
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

  def wrong_format_message(_record, content_item)
    %{Exists in the content store, but is not a "#{format} (it's a "#{content_item.format}"')"}
  end
end
