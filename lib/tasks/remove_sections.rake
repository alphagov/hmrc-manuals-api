desc "Takes a list of slugs of section to remove and makes the appropriate requests to content apis to do so"
task :remove_hmrc_sections, [] => :environment do |_task, args|
  slugs = args.extras
  if slugs.empty?
    puts "Usage: rake remove_hmrc_sections[manual-slug,slug-to-remove-1,slug-to-remove-2,...,slug-to-remove-n]"
  else
    manual_slug = slugs.shift

    slugs.each do |section_slug|
      print "Removing section '#{section_slug}': "
      section = PublishingAPIRemovedSection.new(manual_slug, section_slug)
      TaskHelper.save_and_output(section)
    end
  end
end
