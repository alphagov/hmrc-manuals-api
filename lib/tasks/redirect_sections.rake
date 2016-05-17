desc "Redirect a section, takes original manual slug, section slug, destination manual slug and destination section slug"
task :redirect_hmrc_section, [] => :environment do |_task, args|
  def output_error_message(message)
    puts "ERROR!"
    print "  "
    puts message
  end

  def redirect_and_output(manual)
    response = manual.save!
    if response.code == 200
      puts "OK!"
    else
      output_error_message(response.raw_response_body)
    end
  rescue => e
    output_error_message(e.message)
  end

  slugs = args.extras
  if slugs.empty? || slugs.length < 4
    puts "Usage: rake redirect_hmrc_section[manual-slug,section-slug-to-redirect,destination-manual-slug,destination-section-slug]"
  else
    manual_slug = slugs[0]
    section_slug = slugs[1]
    destination_manual_slug = slugs[2]
    destination_section_slug = slugs[3]

    section = PublishingAPIRedirectedSection.new(manual_slug, section_slug, destination_manual_slug, destination_section_slug)
    redirect_and_output(section)
  end
end
