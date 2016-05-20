require 'gds_api/rummager'

namespace :rummager_republish do
  # Use lambdas because methods in Rake tasks are global, which could
  # cause problems if anyone else were to write more Rake tasks in this
  # app.
  base_path = ->(path) { path.starts_with?('/') ? path : "/#{path}" }
  title_without_section_ids = ->(title, section_id) { title.gsub("#{section_id} - ", "") }

  prepare_section_for_rummager = ->(section) {
    details_hash = {
      'section_id' => section['hmrc_manual_section_id'],
      'body'       => section['indexable_content'],
      'manual'     => { 'base_path' => base_path.call(section['manual']) },
    }

    section_data = {
      'title'             => title_without_section_ids.call(section['title'], section['hmrc_manual_section_id']),
      'description'       => section['description'],
      'public_updated_at' => section['public_timestamp'],
      'details'           => details_hash,
    }
    RummagerSection.new(base_path.call(section['link']), section_data)
  }

  desc 'Republish manual sections to Rummager with a leading slash.'
  task sections_with_leading_slash: :environment do
    rummager = GdsApi::Rummager.new(Plek.current.find('search'))
    # As of 2015-09-17, there are 2345 HMRC manual sections.
    count = 3000

    search_results = rummager.unified_search(filter_format: ['hmrc_manual_section'],
                                             count: count.to_s,
                                             fields: 'title,description,link,indexable_content,public_timestamp,hmrc_manual_section_id,manual')

    raise 'Error: there are more manual sections than you are requesting!' if search_results['total'].to_i > count

    all_sections = search_results['results']
    broken_sections = all_sections.reject { |section| section['manual'].starts_with?('/') }

    broken_sections.each do |section|
      rummager_section = prepare_section_for_rummager.call(section)
      rummager_section.save!
    end

    puts "Number of sections fixed: #{broken_sections.size}."
  end
end
