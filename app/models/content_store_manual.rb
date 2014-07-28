class ContentStoreManual
  def initialize(manual)
    @slug = manual.slug
    @manual_attributes = manual.manual_attributes
  end

  def to_h
    enriched_data = @manual_attributes.clone.merge({
      base_path: manual_base_path,
      format: 'hmrc-manual',
      publishing_app: 'hmrc-manuals-api',
      rendering_app: 'manuals-frontend',
      routes: [{ path: manual_base_path, type: :exact }]
      })
    add_base_path_to_child_section_groups(enriched_data)
  end

private
  def manual_base_path
    "/guidance/#{@slug}"
  end

  def section_base_path(section_id)
    File.join(manual_base_path, section_id)
  end

  def add_base_path_to_child_section_groups(attributes)
    attributes["details"]["child_section_groups"].each do |section_group|
      section_group["child_sections"].each do |section|
        section['base_path'] = section_base_path(section['section_id'])
      end
    end
    attributes
  end
end
