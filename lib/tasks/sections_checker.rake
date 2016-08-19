desc "Takes an array of slugs for either manuals or sections and checks if any sections would be orphaned by their removal"
task :check_sections, [] => :environment do |_task, args|
  if args.extras.empty?
    puts "Pass in some slugs. e.g check_sections['landfill-tax-liability','double-taxation-relief/dt1690pp']"
  else
    args.extras.each do |slug|
      puts "Checking sections for #{slug} . . ."

      children_to_fix = SectionsChecker.new(slug).check

      if children_to_fix.empty?
        puts "OK! Withdrawing #{slug} would not orphan any sections."
      else
        puts "WARNING! Withdrawing #{slug} would orphan #{children_to_fix.count} sections:"
        children_to_fix.each do |child_base_path|
          puts child_base_path
        end
      end
    end
  end
end
