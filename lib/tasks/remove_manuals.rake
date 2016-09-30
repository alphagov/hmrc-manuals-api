desc "Takes a list of slugs of manuals to remove and makes the appropriate requests to content apis to do so"
task :remove_hmrc_manuals, [] => :environment do |_task, args|
  slugs = args.extras
  if slugs.empty?
    puts "Usage: rake remove_hmrc_manuals[slug-to-remove-1,slug-to-remove-2,...,slug-to-remove-n]"
  else
    slugs.each do |manual_slug|
      print "Removing manual '#{manual_slug}': "
      manual = PublishingAPIRemovedManual.new(manual_slug)
      manual.sections.each do |section|
        print "  Removing section '#{manual_slug}/#{section.section_slug}'"
        TaskHelper.save_and_output(section)
      end
      TaskHelper.save_and_output(manual)
    end
  end
end
