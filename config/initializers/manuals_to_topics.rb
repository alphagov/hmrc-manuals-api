require 'manuals_to_topics_loader'

MANUALS_TO_TOPICS = ManualsToTopicsLoader.new(
  IO.read("#{Rails.root}/lib/manuals_to_topics.csv")
).load
