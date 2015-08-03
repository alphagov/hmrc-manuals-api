require 'gds_api/rummager'

desc "Republish manuals to Rummager with a leading slash. Delete the old ones."
task republish_rummager_manuals_leading_slash: :environment do
  rummager = GdsApi::Rummager.new(Plek.current.find('search'))

  # Get all HMRC Manuals.
  manuals = rummager.unified_search(filter_format: ["hmrc_manual"])['results']
  manuals.each do |manual|
    # Add manuals with correct prepended slashes to _id and link fields.
    # Withdraw manuals whose IDs or links don't start with slashes.
    unless manual['_id'].starts_with?('/') && manual['link'].starts_with?('/')
      manual['link'].prepend('/')
      rummager.add_document('hmrc_manual', manual['_id'].prepend('/'), manual)
      rummager.delete_document('hmrc_manual', manual['_id'])
    end
  end
  manuals.each {|m| puts m }
end
