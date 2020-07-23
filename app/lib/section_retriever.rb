class SectionRetriever
  attr_reader :manual_slug

  def initialize(manual_slug)
    @manual_slug = manual_slug
  end

  def sections_from_search_api
    sections = []
    search_response = nil

    loop do
      new_query = search_api_section_query(start_index(search_response))

      search_response = Services.search_api.search(new_query)
      sections += search_response["results"]
      return sections if all_sections_retrieved?(sections, search_response)
    end
  end

private

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

  def search_api_section_query(start_index)
    SearchApiSection.search_query(base_path, start_index)
  end

  def base_path
    PublishingAPIManual.base_path(manual_slug)
  end
end
