module TestDataHelpers
  def valid_manual(options = {})
    {
      title: 'Employment Income Manual',
      description: 'A manual about incoming employment',
      public_updated_at: '2014-01-23T00:00:00+01:00',
      details: {
        child_section_groups: []
      }
    }.merge(options)
  end
end

RSpec.configuration.include TestDataHelpers
