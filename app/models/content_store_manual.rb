class ContentStoreManual
  def initialize(manual)
    @slug = manual.slug
    @manual_attributes = manual.manual_attributes
  end

  def to_h
    enriched_data = @manual_attributes.clone.merge({
      base_path: ContentStoreManual.manual_base_path(@slug),
      format: 'hmrc-manual',
      publishing_app: 'hmrc-manuals-api',
      rendering_app: 'manuals-frontend',
      routes: [{ path: ContentStoreManual.manual_base_path(@slug), type: :exact }]
      })
    add_base_path_to_child_section_groups(enriched_data)
  end

  def self.manual_base_path(manual_slug)
    "/guidance/#{manual_slug}"
  end

  def self.section_base_path(manual_slug, section_id)
    File.join(ContentStoreManual.manual_base_path(manual_slug), section_id)
  end

private
  def add_base_path_to_child_section_groups(attributes)
    attributes["details"]["child_section_groups"].each do |section_group|
      section_group["child_sections"].each do |section|
        section['base_path'] = ContentStoreManual.section_base_path(@slug, section['section_id'])
      end
    end
    attributes
  end
end
