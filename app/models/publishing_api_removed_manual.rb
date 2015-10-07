require 'active_model'
require 'valid_slug/pattern'

class PublishingAPIRemovedManual
  include ActiveModel::Validations

  validates :slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }

  attr_reader :slug

  def initialize(slug)
    @slug = slug
  end

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

  def updates_path
    PublishingAPIManual.updates_path(@slug)
  end

  def save!
    raise ValidationError, "manual to remove is invalid" unless valid?
    publishing_api_response = HMRCManualsAPI.publishing_api.put_content_item(base_path, to_h)

    # rummager_manual = RummagerManual.new(base_path, to_h)
    # rummager_manual.save!

    publishing_api_response
  end

end
