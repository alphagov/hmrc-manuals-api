module PublishingApiDataHelpers
  def maximal_manual_for_publishing_api(options = {})
    {
      "base_path" => "/hmrc-internal-manuals/employment-income-manual",
      "locale" => "en",
      "phase" => "beta",
      "update_type" => "major",
      "document_type" => "hmrc_manual",
      "schema_name" => "hmrc_manual",
      "title" => "Employment Income Manual",
      "description" => "A manual about incoming employment",
      "public_updated_at" => "2014-01-23T00:00:00+01:00",
      "details" => {
        "child_section_groups" => [
          {
            "title" => "A group of sections",
            "child_sections" => [
              {
                "title" => "About 12345",
                "section_id" => "12345",
                "description" => "A short description of the section",
                "base_path" => "/hmrc-internal-manuals/employment-income-manual/12345",
              },
            ],
          },
        ],
        "change_notes" => [
          {
            "base_path" => "/hmrc-internal-manuals/employment-income-manual/abc567",
            "title" => "Title of a Section that was changed",
            "section_id" => "ABC567",
            "change_note" => "Description of changes",
            "published_at" => "2014-01-23T00:00:00+01:00",
          },
          {
            "base_path" => "/hmrc-internal-manuals/employment-income-manual/abc555",
            "title" => "Title of the previous Section that was changed",
            "section_id" => "ABC555",
            "change_note" => "Description of changes",
            "published_at" => "2013-12-23T00:00:00+01:00",
          },
        ],
      },
      "publishing_app" => "hmrc-manuals-api",
      "rendering_app" => "government-frontend",
      "routes" => [
        {
          "path" => "/hmrc-internal-manuals/employment-income-manual",
          "type" => "exact",
        },
        {
          "path" => "/hmrc-internal-manuals/employment-income-manual/updates",
          "type" => "exact",
        },
      ],
    }.merge(options)
  end

  def maximal_manual_update_type
    "major"
  end

  def maximal_section_for_publishing_api(options = {})
    {
      "base_path" => "/hmrc-internal-manuals/employment-income-manual/12345",
      "document_type" => "hmrc_manual_section",
      "update_type" => "minor",
      "schema_name" => "hmrc_manual_section",
      "locale" => "en",
      "phase" => "beta",
      "title" => "A section on a part of employment income",
      "description" => "Some description",
      "public_updated_at" => "2014-01-23T00:00:00+01:00",
      "details" => {
        "body" => "<p>I need <strong>somebody</strong> to love</p>\n",
        "section_id" => "12345",
        "manual" => {
          "base_path" => "/hmrc-internal-manuals/employment-income-manual",
          "title" => "Employment Income Manual",
        },
        "breadcrumbs" => [
          {
            "section_id" => "1234",
            "base_path" => "/hmrc-internal-manuals/employment-income-manual/1234",
          },
        ],
        "child_section_groups" => [
          {
            "title" => "A group of sections",
            "child_sections" => [
              {
                "title" => "About 123456",
                "section_id" => "123456",
                "description" => "A short description of the section",
                "base_path" => "/hmrc-internal-manuals/employment-income-manual/123456",
              },
            ],
          },
        ],
      },
      "publishing_app" => "hmrc-manuals-api",
      "rendering_app" => "government-frontend",
      "routes" => [
        {
          "path" => "/hmrc-internal-manuals/employment-income-manual/12345",
          "type" => "exact",
        },
      ],
    }.merge(options)
  end

  def gone_manual_for_publishing_api(base_path: "/hmrc-internal-manuals/some-slug")
    {
      "base_path" => base_path,
      "document_type" => "gone",
      "schema_name" => "gone",
      "update_type" => "major",
      "publishing_app" => "hmrc-manuals-api",
      "routes" => [
        {
          "path" => base_path,
          "type" => "exact",
        },
        {
          "path" => "#{base_path}/updates",
          "type" => "exact",
        },
      ],
    }
  end

  def gone_manual_section_for_publishing_api(manual_slug: "some-manual", section_slug: "some-section")
    {
      "base_path" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
      "document_type" => "gone",
      "schema_name" => "gone",
      "update_type" => "major",
      "publishing_app" => "hmrc-manuals-api",
      "routes" => [
        {
          "path" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
          "type" => "exact",
        },
      ],
    }
  end

  def redirected_manual_section_to_other_manual_section_for_publishing_api(manual_slug: "some-manual", section_slug: "some-section", dest_manual_slug: "some-other-manual", dest_section_slug: "some-other-section")
    {
      "document_type" => "redirect",
      "schema_name" => "redirect",
      "publishing_app" => "hmrc-manuals-api",
      "base_path" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
      "redirects" => [
        {
          "path" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
          "type" => "exact",
          "destination" => "/hmrc-internal-manuals/#{dest_manual_slug}/#{dest_section_slug}",
        },
      ],
      "update_type" => "major",
    }
  end

  def redirected_manual_section_to_other_manual_for_publishing_api(manual_slug: "some-manual", section_slug: "some-section", dest_manual_slug: "some-other-manual")
    {
      "document_type" => "redirect",
      "schema_name" => "redirect",
      "publishing_app" => "hmrc-manuals-api",
      "base_path" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
      "redirects" => [
        {
          "path" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
          "type" => "exact",
          "destination" => "/hmrc-internal-manuals/#{dest_manual_slug}",
        },
      ],
      "update_type" => "major",
    }
  end

  def redirected_manual_section_to_parent_manual_for_publishing_api(manual_slug: "some-manual", section_slug: "some-section")
    {
      "document_type" => "redirect",
      "schema_name" => "redirect",
      "publishing_app" => "hmrc-manuals-api",
      "base_path" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
      "redirects" => [
        {
          "path" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
          "type" => "exact",
          "destination" => "/hmrc-internal-manuals/#{manual_slug}",
        },
      ],
      "update_type" => "major",
    }
  end

  def redirected_manual_to_other_manual_for_publishing_api(manual_slug: "some-manual", destination_manual_slug: "some-other-manual")
    {
      "document_type" => "redirect",
      "schema_name" => "redirect",
      "publishing_app" => "hmrc-manuals-api",
      "base_path" => "/hmrc-internal-manuals/#{manual_slug}",
      "redirects" => [
        {
          "path" => "/hmrc-internal-manuals/#{manual_slug}",
          "type" => "exact",
          "destination" => "/hmrc-internal-manuals/#{destination_manual_slug}",
        },
      ],
      "update_type" => "major",
    }
  end
end

RSpec.configuration.include PublishingApiDataHelpers
