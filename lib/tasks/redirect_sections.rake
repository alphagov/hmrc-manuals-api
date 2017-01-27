desc "Redirect a section, takes original manual slug, section slug, destination manual slug and (optional) destination section slug"
task :redirect_hmrc_section, [] => :environment do |_task, args|
  slugs = args.extras
  if slugs.empty? || slugs.length < 3
    puts %{Usage:
  rake redirect_hmrc_section[manual-slug,section-slug-to-redirect,destination-manual-slug]
or
  rake redirect_hmrc_section[manual-slug,section-slug-to-redirect,destingation-manual-slug,destination-section-slug]
}
  else
    manual_slug = slugs[0]
    section_slug = slugs[1]
    destination_manual_slug = slugs[2]
    destination_section_slug = slugs[3]

    section = PublishingAPIRedirectedSection.new(manual_slug, section_slug, destination_manual_slug, destination_section_slug)
    TaskHelper.save_and_output(section)
  end
end

desc "Redirect a section to its parent manual, takes original manual slug, section slug, destination manual slug"
task :redirect_hmrc_section_to_parent_manual, [] => :environment do |_task, args|
  slugs = args.extras
  if slugs.empty? || slugs.length < 2
    puts "Usage: rake redirect_hmrc_section_to_parent_manual[manual-slug,section-slug-to-redirect]"
  else
    manual_slug = slugs[0]
    section_slug = slugs[1]

    section = PublishingAPIRedirectedSectionToParentManual.new(manual_slug, section_slug)
    TaskHelper.save_and_output(section)
  end
end

desc "Redirect all sections in a manual to the parent manual, takes manual slug"
task :redirect_all_hmrc_sections_to_parent_manual, [] => :environment do |_task, args|
  slugs = args.extras
  if slugs.empty?
    puts "Usage: rake redirect_all_hmrc_sections_to_parent_manual[manual-slug]"
  else
    manual_slug = slugs[0]

    sections = SectionRetriever.new(manual_slug).sections_from_rummager.map do |json|
      PublishingAPIRedirectedSectionToParentManual.from_rummager_result(json)
    end
    puts "Redirecting #{sections.count} sections"
    sections.each do |section|
      puts "\tRedirecting #{section.manual_slug}/#{section.section_slug} > #{section.manual_slug}"
      TaskHelper.save_and_output(section)
    end
  end
end
