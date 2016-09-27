require 'active_model'
require 'valid_slug/pattern'

class PublishingAPIRemovedManual
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validates_with InContentStoreValidator,
    format: MANUAL_FORMAT,
    content_store: Services.content_store,
    unless: -> { errors[:slug].present? }

  attr_accessor :slug

  def initialize(slug)
    @slug = slug
  end

  def sections
    sections_from_rummager.map do |section_json|
      PublishingAPIRemovedSection.from_rummager_result(section_json)
    end
  end

  def sections_from_rummager
    sections = []
    search_response = nil

    loop do
      new_query = rummager_section_query(start_index(search_response))

      search_response = Services.rummager.search(new_query)
      sections += search_response["results"]
      return sections if all_sections_retrieved?(sections, search_response)
    end
  end

  private :sections_from_rummager

  def all_sections_retrieved?(sections, search_response)
    sections.count >= search_response["total"]
  end

  def start_index(search_response)
    if search_response
      search_response["start"] + search_response["results"].count
    else
      0
    end
  end

  def rummager_section_query(start_index)
    RummagerSection.search_query(base_path, start_index)
  end

  def to_h
    @_to_h ||= {
      base_path: base_path,
      document_type: 'gone',
      schema_name: 'gone',
      publishing_app: 'hmrc-manuals-api',
      update_type: update_type,
      routes: [
        { path: base_path, type: :exact },
        { path: updates_path, type: :exact },
      ],
    }
  end

  def content_id
    base_path_uuid
  end

  def update_type
    'major'
  end

  def base_path
    PublishingAPIManual.base_path(@slug)
  end

  def updates_path
    PublishingAPIManual.updates_path(@slug)
  end

  def save!
    raise ValidationError, "manual to remove is invalid #{errors.full_messages.to_sentence}" unless valid?
    publishing_api_response = PublishingAPINotifier.new(self).notify(update_links: false)
    Services.rummager.delete_document(MANUAL_FORMAT, base_path)
    publishing_api_response
  end
end
