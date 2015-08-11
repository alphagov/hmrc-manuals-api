require 'gds_api/rummager'

namespace :rummager_republish do

  # Use lambdas because methods in Rake tasks are global, which could
  # cause problems if anyone else were to write more Rake tasks in this
  # app.
  base_path = ->(path) { path.starts_with?('/') ? path : "/#{path}" }

  prepare_manual_for_rummager = ->(manual) {
    manual_data = {
      'title'             => manual['title'],
      'description'       => manual['description'],
      'public_updated_at' => manual['last_update'],
    }
    RummagerManual.new(base_path.call(manual['link']), manual_data)
  }

  prepare_section_for_rummager = ->(section) {
    details_hash = {
      'section_id' => section['hmrc_manual_section_id'],
      'body'       => section['indexable_content'],
      'manual'     => { 'base_path' => base_path.call(section['manual']) },
    }

    section_data = {
      'title'             => section['title'],
      'description'       => section['description'],
      'public_updated_at' => section['last_update'],
      'details'           => details_hash,
    }
    RummagerSection.new(base_path.call(section['link']), section_data)
  }

  desc 'Republish manuals to Rummager with a leading slash. Delete the old ones.'
  task manuals_with_leading_slash: :environment do
    rummager = GdsApi::Rummager.new(Plek.current.find('search'))
    # As of 2015-08-05, there are 5 HMRC manuals. This is a one-off
    # script to add leading slashes to manuals, and all new manuals
    # they publish will have leading slashes by default.
    count = 10

    search_results = rummager.unified_search(filter_format: ['hmrc_manual'],
                                             count: count.to_s,
                                             fields: 'title,description,link,indexable_content,last_update')

    raise 'Error: there are more manuals than you are requesting!' if search_results['total'].to_i > count

    all_manuals = search_results['results']
    broken_manuals = all_manuals.reject { |manual|
      manual['_id'].starts_with?('/') && manual['link'].starts_with?('/')
    }

    broken_manuals.each do |manual|
      rummager.delete_document('hmrc_manual', manual['_id'])

      rummager_manual = prepare_manual_for_rummager.call(manual)

      rummager_manual.save!
    end
    puts "Number of manuals fixed: #{broken_manuals.size}."
  end

  desc 'Republish manual sections to Rummager with a leading slash. Delete the old ones.'
  task sections_with_leading_slash: :environment do
    rummager = GdsApi::Rummager.new(Plek.current.find('search'))
    # As of 2015-08-05, there are 2339 HMRC manual sections. This is a
    # one-off script to add leading slashes to manual sections, as all
    # new manuals they publish will have sections with leading slashes
    # by default.
    count = 3000

    search_results = rummager.unified_search(filter_format: ['hmrc_manual_section'],
                                             count: count.to_s,
                                             fields: 'title,description,link,indexable_content,last_update,hmrc_manual_section_id,manual')

    raise 'Error: there are more manual sections than you are requesting!' if search_results['total'].to_i > count

    all_sections = search_results['results']
    broken_sections = all_sections.reject { |section|
      section['_id'].starts_with?('/') && section['link'].starts_with?('/')
    }

    broken_sections.each do |section|
      rummager.delete_document(SECTION_FORMAT, section['_id'])

      rummager_section = prepare_section_for_rummager.call(section)
      rummager_section.save!
    end

    puts "Number of sections fixed: #{broken_sections.size}."
  end
end
