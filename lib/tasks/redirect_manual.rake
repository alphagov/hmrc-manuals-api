desc "Redirect a manual, takes original manual slug, destination manual slug"
task :redirect_hmrc_manual, [] => :environment do |_task, args|
  slugs = args.extras
  if slugs.empty? || slugs.length < 2
    puts %(Usage: rake redirect_hmrc_manual[manual_slug, destination_slug])
  else
    manual_slug = slugs[0]
    destination_slug = slugs[1]

    manual = PublishingAPIRedirectedManual.new(manual_slug, destination_slug)
    TaskHelper.save_and_output(manual)
  end
end
