require 'csv'

desc "Map manual topic slugs to content IDs"
task map_manual_topic_slugs_to_content_ids: :environment do
  topics = HMRCManualsAPI.content_register.entries('topic').to_a

  csv = CSV.read("#{Rails.root}/lib/topic_slugs_to_content_ids.csv")

  CSV.open("#{Rails.root}/lib/topic_slugs_to_content_ids_regenerated.csv", "w") do |new_csv|
    new_csv << csv.shift
    csv.each do |row|
      slugs = row[1].split(",")
      content_ids = []
      slugs.each do |slug|
        topic = topics.select {|topic| topic["base_path"] == "/topic/#{slug}"}.first
        if topic
          content_ids << topic["content_id"]
        else
          puts "Couldn't find content ID for #{slug}."
        end
      end
      new_csv << [row[0],row[1],content_ids.join(",")]
    end
  end
end

