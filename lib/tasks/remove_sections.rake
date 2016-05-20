desc "Takes a list of slugs of section to remove and makes the appropriate requests to content apis to do so"
task :remove_hmrc_sections, [] => :environment do |_task, args|
  def output_error_message(message)
    puts "ERROR!"
    print "  "
    puts message
  end

  def remove_and_output(section)
    response = section.save!
    if response.code == 200
      puts "OK!"
    else
      output_error_message(response.raw_response_body)
    end
  rescue => e
    output_error_message(e.message)
  end

  slugs = args.extras
  if slugs.empty?
    puts "Usage: rake remove_hmrc_sections[manual-slug,slug-to-remove-1,slug-to-remove-2,...,slug-to-remove-n]"
  else
    manual_slug = slugs.shift

    slugs.each do |section_slug|
      print "Removing section '#{section_slug}': "
      section = PublishingAPIRemovedSection.new(manual_slug, section_slug)
      remove_and_output(section)
    end
  end
end
