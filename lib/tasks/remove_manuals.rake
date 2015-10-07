desc "Takes a list of slugs of manuals to remove and makes the appropriate requests to content apis to do so"
task :remove_hmrc_manuals, [] => :environment do |_task, args|
  def output_error_message(message)
    puts "ERROR!"
    print "  "
    puts message
  end

  def remove_and_output(manual)
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
  if slugs.empty?
    puts "Usage: rake remove_hmrc_manuals[slug-to-remove-1,slug-to-remove-2,...,slug-to-remove-n]"
  else
    slugs.each do |manual_slug|
      print "Removing manual '#{manual_slug}': "
      manual = PublishingAPIRemovedManual.new(manual_slug)
      remove_and_output(manual)
    end
  end
end
