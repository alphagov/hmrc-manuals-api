namespace :single_use do
  task manual_section_links: :environment do
    content_ids = YAML.load_file(File.expand_path("../hmrc_manual_sections_links_update.yaml", __FILE__))["content_ids"]

    content_ids.each do |content_id|
      begin
        retries ||= 5
        puts "--> Patching #{content_id}"
        Services.publishing_api.patch_links(
          content_id,
          links: { organisations: ["6667cce2-e809-4e21-ae09-cb0bdc1ddda3"] }
        )
      rescue => e
        puts e.message
        unless (retries -= 1).zero?
          puts "...retrying"
          retry
        end
      end
    end
  end
end
