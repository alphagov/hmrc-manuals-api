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

  def maximal_manual(options = {})
    {
      title: 'Employment Income Manual',
      description: 'A manual about incoming employment',
      public_updated_at: '2014-01-23T00:00:00+01:00',
      details: {
        child_section_groups: [
          {
            title: 'A group of sections',
            child_sections: [
              {
                title: 'About 12345',
                section_id: '12345',
                description: 'A short description of the section'
              }
            ]
          }
        ],
        change_notes: "Description of change to section"
      }
    }.merge(options)
  end

  def valid_section(options = {})
    {
      title: 'A section on a part of employment income',
      public_updated_at: '2014-01-23T00:00:00+01:00',
      details: {
        section_id: "12345",
        manual: {
          title: 'Employment Income Manual',
          slug: 'employment-income-manual',
        }
      }
    }
  end
end

RSpec.configuration.include TestDataHelpers
