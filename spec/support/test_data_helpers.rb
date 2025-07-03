require "active_support"

module TestDataHelpers
  def maximal_manual_slug
    "employment-income-manual"
  end

  def maximal_manual_base_path
    "/hmrc-internal-manuals/employment-income-manual"
  end

  def maximal_manual_content_id
    "913fd52f-072c-409e-88b2-ea0b7a8b6d9c"
  end

  def maximal_manual_url
    "https://www.gov.uk/hmrc-internal-manuals/employment-income-manual"
  end

  def maximal_section_slug
    "12345"
  end

  def maximal_section_base_path
    "/hmrc-internal-manuals/employment-income-manual/12345"
  end

  def maximal_section_url
    "https://www.gov.uk/hmrc-internal-manuals/employment-income-manual/12345"
  end

  def valid_manual(options = {})
    {
      title: "Employment Income Manual",
      description: "A manual about incoming employment",
      public_updated_at: "2014-01-23T00:00:00+01:00",
      update_type: "minor",
      details: {
        child_section_groups: [],
        change_notes: [],
      },
    }.merge(options).deep_stringify_keys
  end

  def maximal_manual(options = {})
    {
      title: "Employment Income Manual",
      content_id: maximal_manual_content_id,
      description: "A manual about incoming employment",
      public_updated_at: "2014-01-23T00:00:00+01:00",
      update_type: "major",
      details: {
        child_section_groups: [
          {
            title: "A group of sections",
            child_sections: [
              {
                title: "About 12345",
                section_id: "12345",
                description: "A short description of the section",
              },
            ],
          },
        ],
        change_notes: [
          {
            title: "Title of a Section that was changed",
            section_id: "ABC567",
            change_note: "Description of changes",
            published_at: "2014-01-23T00:00:00+01:00",
          },
          {
            title: "Title of the previous Section that was changed",
            section_id: "ABC555",
            change_note: "Description of changes",
            published_at: "2013-12-23T00:00:00+01:00",
          },
        ],
      },
    }.merge(options).deep_stringify_keys
  end

  def manual_with_top_level_change_note
    {
      title: "Employment Income Manual",
      content_id: maximal_manual_content_id,
      description: "A manual about incoming employment",
      public_updated_at: "2014-01-23T00:00:00+01:00",
      update_type: "major",
      details: {
        child_section_groups: [],
        change_notes: [
          {
            title: "Title of the manual that was changed",
            section_id: nil,
            change_note: "Description of changes",
            published_at: "2014-01-23T00:00:00+01:00",
          },
          {
            title: "Title of the section that was changed",
            section_id: "ABC555",
            change_note: "Description of changes",
            published_at: "2013-12-23T00:00:00+01:00",
          },
        ],
      },
    }.deep_stringify_keys
  end

  def manual_without_change_note_titles(options = {})
    {
      title: "Employment Income Manual",
      description: "A manual about incoming employment",
      public_updated_at: "2014-01-23T00:00:00+01:00",
      update_type: "minor",
      details: {
        child_section_groups: [],
        change_notes: [
          {
            title: "",
            section_id: "ABC567",
            change_note: "Description of changes",
            published_at: "2014-01-23T00:00:00+01:00",
          },
          {
            title: "",
            section_id: "ABC555",
            change_note: "Description of changes",
            published_at: "2013-12-23T00:00:00+01:00",
          },
        ],
      },
    }.merge(options).deep_stringify_keys
  end

  def valid_section(options = {})
    {
      title: "A section on a part of employment income",
      public_updated_at: "2014-01-23T00:00:00+01:00",
      update_type: "major",
      details: {
        section_id: "12345",
      },
    }.merge(options).deep_stringify_keys
  end

  def maximal_section_content_id
    "25e687b8-74da-4892-938d-7de82fa5df27"
  end

  # This is what comes in from hmrc
  def maximal_section(options = {})
    {
      title: "A section on a part of employment income",
      content_id: maximal_section_content_id,
      description: "Some description",
      public_updated_at: "2014-01-23T00:00:00+01:00",
      update_type: "minor",
      details: {
        body: "I need **somebody** to love",
        section_id: "12345",
        breadcrumbs: [
          {
            section_id: "1234",
          },
        ],
        child_section_groups: [
          title: "A group of sections",
          child_sections: [
            {
              title: "About 123456",
              section_id: "123456",
              description: "A short description of the section",
            },
          ],
        ],
      },
    }.merge(options).deep_stringify_keys
  end
end

RSpec.configuration.include TestDataHelpers
