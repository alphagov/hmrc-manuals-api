class Topics
  def initialize(manual_slug:, manuals_to_topics: MANUALS_TO_TOPICS, content_register: Services.content_register)
    @manual_slug = manual_slug
    @manuals_to_topics = manuals_to_topics
    @content_register = content_register
  end

  def content_ids
    @content_ids ||= manuals_to_topics[manual_slug] || []
  end

  def slugs
    @slugs ||= matching_topics.map { |topic|
      format_slug(topic)
    }
  end

private
  attr_reader :manual_slug, :manuals_to_topics, :content_register

  def matching_topics
    return [] if content_ids.empty?

    all_available_topics.select { |topic|
      content_ids.include?(topic['content_id'])
    }
  end

  def format_slug(topic)
    topic['base_path'].sub('/topic/', '')
  end

  def all_available_topics
    @all_available_topics ||= content_register.entries('topic').to_a
  end
end
