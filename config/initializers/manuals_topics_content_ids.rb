require 'manuals_topics_content_ids_loader'

MANUALS_TOPICS_CONTENT_IDS = ManualsTopicsContentIdsLoader.new(
  IO.read("#{Rails.root}/lib/manuals_to_topics.csv")
).load
