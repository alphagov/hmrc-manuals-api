require 'active_model'
require 'valid_slug/pattern'

class PublishingAPIRemovedManual
  include ActiveModel::Validations

  validates :slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }

  attr_reader :slug

  def initialize(slug)
    @slug = slug
  end

  def sections
    sections_from_rummager.map do |section_json|
      PublishingAPIRemovedSection.from_rummager_result(section_json)
    end
  end

  def sections_from_rummager
    query = RummagerSection.search_query(base_path)
    HMRCManualsAPI.rummager.unified_search(query).results
  end
  private :sections_from_rummager

  def to_h
    @_to_h ||= {
      format: 'gone',
      publishing_app: 'hmrc-manuals-api',
      update_type: 'major',
      routes: [
        { path: base_path, type: :exact },
        { path: updates_path, type: :exact },
      ],
    }
  end

  def base_path
    PublishingAPIManual.base_path(@slug)
  end

  def base_path_for_rummager
    base_path.sub(/\A\//,'')
  end

  def updates_path
    PublishingAPIManual.updates_path(@slug)
  end

  def save!
    raise ValidationError, "manual to remove is invalid" unless valid?
    publishing_api_response = HMRCManualsAPI.publishing_api.put_content_item(base_path, to_h)

    HMRCManualsAPI.rummager.delete_document(MANUAL_FORMAT, base_path_for_rummager)

    publishing_api_response
  end

end
