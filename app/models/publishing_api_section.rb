require "active_model"

class PublishingAPISection
  include ActiveModel::Validations
  include Helpers::PublishingAPIHelpers

  validates :to_h, no_dangerous_html_in_text_fields: true, if: -> { @section.valid? }
  validates :manual_slug, :section_slug, format: { with: ValidSlug::PATTERN, message: "should match the pattern: #{ValidSlug::PATTERN}" }
  validate :incoming_section_is_valid
  validate :section_slug_matches_section_id, if: -> { @section.valid? }

  attr_accessor :manual_slug, :section_slug, :section_attributes

  def initialize(manual_slug, section_slug, section_attributes)
    @manual_slug = manual_slug
    @section_slug = section_slug
    @section_attributes = section_attributes
    @section = Section.new(section_attributes)
    generate_content_id_if_absent
  end

  def to_h
    @to_h ||= begin
      enriched_data = @section_attributes.except("content_id").deep_dup.merge(
        base_path:,
        document_type: SECTION_DOCUMENT_TYPE,
        schema_name: SECTION_SCHEMA_NAME,
        publishing_app: "hmrc-manuals-api",
        rendering_app: "government-frontend",
        routes: [{ path: PublishingAPISection.base_path(@manual_slug, @section_slug), type: :exact }],
        locale: "en",
        phase: "live",
      )
      enriched_data = StructWithRenderedMarkdown.new(enriched_data).to_h
      enriched_data = add_base_path_to_child_section_groups(enriched_data)
      enriched_data = add_base_path_to_breadcrumbs(enriched_data)
      add_base_path_to_manual(enriched_data)
    end
  end

  def links
    LinksBuilder.new(content_id).build_links
  end

  def content_id
    @section_attributes["content_id"]
  end

  def update_type
    section_attributes["update_type"]
  end

  def govuk_url
    FRONTEND_BASE_URL + base_path
  end

  def base_path
    PublishingAPISection.base_path(@manual_slug, @section_slug)
  end

  def self.base_path(manual_slug, section_slug)
    # The section_slug may not be lowercase - for example if it is extracted
    # from a section_id field.
    File.join(PublishingAPIManual.base_path(manual_slug.to_s.downcase), section_slug.to_s.downcase)
  end

  def self.find_title(base_path)
    item = Services.content_store.content_item(base_path)
    item.to_h["title"]
  end

  def self.extract_slugs_from_path(path)
    slugs = {}
    slugs[:manual] = PublishingAPIManual.extract_slug_from_path(path)
    slugs[:section] = path.split("/", 5).fourth
    raise InvalidPathError if slugs[:section].blank?

    slugs
  end

  def save!
    raise ValidationError, "section is invalid" unless valid?

    PublishingAPINotifier.new(self).notify
  end

private

  def generate_content_id_if_absent
    if @section_attributes.is_a?(Hash) && !@section_attributes["content_id"]
      @section_attributes["content_id"] = base_path_uuid
    end
  end

  def add_base_path_to_child_section_groups(attributes)
    # child_section_groups isn't required for sections, so might be nil:
    (attributes["details"]["child_section_groups"] || []).each do |section_group|
      section_group["child_sections"].each do |section|
        section["base_path"] = PublishingAPISection.base_path(@manual_slug, section["section_id"])
      end
    end
    attributes
  end

  def add_base_path_to_breadcrumbs(attributes)
    # breadcrumbs isn't required, so might be nil:
    (attributes["details"]["breadcrumbs"] || []).each do |section|
      section["base_path"] = PublishingAPISection.base_path(@manual_slug, section["section_id"])
    end
    attributes
  end

  def add_base_path_to_manual(attributes)
    attributes["details"]["manual"] = {
      "base_path" => PublishingAPIManual.base_path(@manual_slug),
    }
    attributes
  end

  def incoming_section_is_valid
    unless @section.valid?
      @section.errors.full_messages.each { |message| errors.add(:base, message) }
    end
  end

  def section_slug_matches_section_id
    unless section_slug.to_s.casecmp(section_attributes["details"]["section_id"].downcase).zero?
      errors.add(:base, "Slug in URL and Section ID must match, ignoring case")
    end
  end
end
