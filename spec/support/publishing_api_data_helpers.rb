module PublishingApiDataHelpers
  def maximal_manual_for_publishing_api(options = {})
    {
      "format" => "hmrc_manual",
      "title" => "Employment Income Manual",
      "description" => "A manual about incoming employment",
      "public_updated_at" => "2014-01-23T00:00:00+01:00",
      "details" => {
        "child_section_groups" => [
          {
            "title" => 'A group of sections',
            "child_sections" => [
              {
                "title" => "About 12345",
                "section_id" => "12345",
                "description" => "A short description of the section",
                "base_path" => "/hmrc-internal-manuals/employment-income-manual/12345"
              }
            ]
          }
        ],
        "organisations" => [
          {
            "title" => "HM Revenue & Customs",
            "abbreviation" => "HMRC",
            "web_url" => "https://www.gov.uk/government/organisations/hm-revenue-customs"
          }
        ],
        "change_notes" => [
          {
            "base_path" => "/hmrc-internal-manuals/employment-income-manual/abc567",
            "title" => 'Title of a Section that was changed',
            "section_id" => 'ABC567',
            "change_note" => 'Description of changes',
            "published_at" => '2014-01-23T00:00:00+01:00'
          },
          {
            "base_path" => "/hmrc-internal-manuals/employment-income-manual/abc555",
            "title" => "Title of the previous Section that was changed",
            "section_id" => "ABC555",
            "change_note" => "Description of changes",
            "published_at" => "2013-12-23T00:00:00+01:00"
          }
        ]
      },
      "publishing_app" => "hmrc-manuals-api",
      "rendering_app" => "manuals-frontend",
      "routes" => [
        {
          "path" => "/hmrc-internal-manuals/employment-income-manual",
          "type" => "exact"
        },
        {
          "path" => "/hmrc-internal-manuals/employment-income-manual/updates",
          "type" => "exact"
        },
      ],
    }.merge(options)
  end

  def maximal_manual_update_type
    'major'
  end

  def maximal_section_for_publishing_api(options = {})
    {
      "format" => "hmrc_manual_section",
      "title" => "A section on a part of employment income",
      "description" => "Some description",
      "public_updated_at" => "2014-01-23T00:00:00+01:00",
      "details" => {
        "body" => "<p>I need <strong>somebody</strong> to love</p>\n",
        "section_id" => "12345",
        "manual" => {
          "base_path" => "/hmrc-internal-manuals/employment-income-manual"
        },
        "breadcrumbs" => [
          {
            "section_id" => "1234",
            "base_path" => "/hmrc-internal-manuals/employment-income-manual/1234"
          }
        ],
        "child_section_groups" => [
          {
            "title" => 'A group of sections',
            "child_sections" => [
              {
                "title" => "About 123456",
                "section_id" => "123456",
                "description" => "A short description of the section",
                "base_path" => "/hmrc-internal-manuals/employment-income-manual/123456"
              }
            ]
          }
        ],
        "organisations" => [
          {
            "title" => "HM Revenue & Customs",
            "abbreviation" => "HMRC",
            "web_url" => "https://www.gov.uk/government/organisations/hm-revenue-customs"
          }
        ]
      },
      "publishing_app" => "hmrc-manuals-api",
      "rendering_app" => "manuals-frontend",
      "routes" => [
        {
          "path" => "/hmrc-internal-manuals/employment-income-manual/12345",
          "type" => "exact"
        }
      ]
    }.merge(options)
  end

  def gone_manual_for_publishing_api(base_path: '/hmrc-internal-manuals/some-slug')
    {
      'base_path' => base_path,
      'format' => 'gone',
      'publishing_app' => 'hmrc-manuals-api',
      'routes' => [
        {
          'path' => base_path,
          'type' => 'exact',
        },
        {
          'path' => "#{base_path}/updates",
          'type' => 'exact',
        },
      ],
    }
  end

  def gone_manual_section_for_publishing_api(manual_slug: 'some-manual', section_slug: 'some-section')
    {
      'format' => 'gone',
      'publishing_app' => 'hmrc-manuals-api',
      'routes' => [
        {
          'path' => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
          'type' => 'exact',
        },
      ],
    }
  end
end

RSpec.configuration.include PublishingApiDataHelpers
