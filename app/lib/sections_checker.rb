class SectionsChecker
  def initialize(item_slug)
    @item_slug = item_slug
  end

  def check
    item = content_item(item_base_path)

    children = child_sections(item)

    if item["schema_name"] == MANUAL_SCHEMA_NAME
      check_children_of_manual(item, children)
    elsif item["schema_name"] == SECTION_SCHEMA_NAME
      check_children_of_section(item, children)
    end
  end

private

  def item_base_path
    PublishingAPIManual.base_path(@item_slug)
  end

  def content_item(base_path)
    Services.content_store.content_item(base_path)
  end

  def child_sections(item)
    item["details"]["child_section_groups"].flat_map do |group|
      group["child_sections"]
    end
  end

  def check_children_of_manual(manual, children)
    find_children_of_parent_manual(children, manual).map do |child|
      child["base_path"]
    end
  end

  def find_children_of_parent_manual(children, parent_manual)
    children.select do |child|
      child_to_check = content_item(child["base_path"])
      belongs_to_parent_manual?(child_to_check, parent_manual)
    end
  end

  def belongs_to_parent_manual?(child, parent_manual)
    if child["details"]["manual"]["base_path"] == parent_manual["base_path"]
      true
    else
      parent = content_item(child["details"]["manual"]["base_path"])
      !child_section_in_tree?(parent, child)
    end
  end

  def child_section_in_tree?(parent, child)
    child_sections(parent).each do |child_section|
      if child_section["base_path"] == child["base_path"] ||
          child_section_in_tree?(content_item(child_section["base_path"]), child)
        return true
      end
    end
    false
  end

  def check_children_of_section(section, children)
    find_children_of_parent_section(children, section).map do |child|
      child["base_path"]
    end
  end

  def find_children_of_parent_section(children, parent_section)
    children.select do |child|
      child_to_check = content_item(child["base_path"])
      belongs_to_parent_section?(child_to_check, parent_section)
    end
  end

  def belongs_to_parent_section?(child, parent_section)
    parent_to_check = child["details"]["breadcrumbs"].last

    if parent_to_check["base_path"] == parent_section["base_path"]
      true
    else
      !child_section_has_new_parent?(parent_to_check["base_path"], child)
    end
  end

  def child_section_has_new_parent?(base_path, child)
    section = child_sections(content_item(base_path)).detect do |child_section|
      child_section["base_path"] == child["base_path"]
    end
    section.present?
  end
end
