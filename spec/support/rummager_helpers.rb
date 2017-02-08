module RummagerHelpers
  def maximal_manual_for_rummager
    {
      'content_id'         => '913fd52f-072c-409e-88b2-ea0b7a8b6d9c',
      'title'              => 'Employment Income Manual',
      'description'        => 'A manual about incoming employment',
      'content_store_document_type' => 'hmrc_manual',
      'link'               => '/hmrc-internal-manuals/employment-income-manual',
      'indexable_content'  => nil,
      'public_timestamp'   => '2014-01-23T00:00:00+01:00',
      'format'             => 'hmrc_manual',
      'latest_change_note' => 'Description of changes in Title of a Section that was changed'
    }
  end

  def maximal_section_for_rummager
    {
      'content_id'             => '25e687b8-74da-4892-938d-7de82fa5df27',
      'title'                  => '12345 - A section on a part of employment income',
      'description'            => 'Some description',
      'content_store_document_type' => 'hmrc_manual_section',
      'link'                   => '/hmrc-internal-manuals/employment-income-manual/12345',
      'indexable_content'      => 'I need somebody to love', # Markdown/HTML has been stripped
      'public_timestamp'       => '2014-01-23T00:00:00+01:00',
      'hmrc_manual_section_id' => '12345',
      'manual'                 => '/hmrc-internal-manuals/employment-income-manual',
      'format'                 => 'hmrc_manual_section',
    }
  end

  def no_manual_sections_rummager_json_result
    <<-JSON.strip_heredoc
      {
        "results":[],
        "total":0,
        "start":0,
        "facets":{},
        "suggested_queries":[]
      }
    JSON
  end

  def single_section_parsed_rummager_json_result(manual_slug, section_slug = 'section-1')
    {
      "format" => "hmrc_manual_section",
      "link" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
      "organisations" => [
        {
          "slug" => "hm-revenue-customs",
          "title" => "HM Revenue & Customs",
          "acronym" => "HMRC",
          "organisation_state" => "live",
          "link" => "/government/organisations/hm-revenue-customs"
        }
      ],
      "public_timestamp" => "2015-02-03T16:30:33+00:00",
      "title" => "section 1",
      "index" => "mainstream",
      "es_score" => nil,
      "_id" => "/hmrc-internal-manuals/#{manual_slug}/#{section_slug}",
      "document_type" => "hmrc_manual_section"
    }
  end

  def two_manual_sections_rummager_json_result(manual_slug)
    <<-JSON.strip_heredoc
      {
        "results":[
          {
            "format":"hmrc_manual_section",
            "link":"/hmrc-internal-manuals/#{manual_slug}/section-1",
            "organisations":[
              {
                "slug":"hm-revenue-customs",
                "title":"HM Revenue & Customs",
                "acronym":"HMRC",
                "organisation_state":"live",
                "link":"/government/organisations/hm-revenue-customs"
              }
            ],
            "public_timestamp":"2015-02-03T16:30:33+00:00",
            "title":"section 1",
            "index":"mainstream",
            "es_score":null,
            "_id":"/hmrc-internal-manuals/#{manual_slug}/section-1",
            "document_type":"hmrc_manual_section"
          },
          {
            "format":"hmrc_manual_section",
            "link":"/hmrc-internal-manuals/#{manual_slug}/section-2",
            "organisations":[
              {
                "slug":"hm-revenue-customs",
                "title":"HM Revenue & Customs",
                "acronym":"HMRC",
                "organisation_state":"live",
                "link":"/government/organisations/hm-revenue-customs"
              }
            ],
            "public_timestamp":"2015-02-10T15:56:49+00:00",
            "title":"section 2",
            "index":"mainstream",
            "es_score":null,
            "_id":"/hmrc-internal-manuals/#{manual_slug}/section-2",
            "document_type":"hmrc_manual_section"
          }
        ],
        "total":2,
        "start":0,
        "facets":{},
        "suggested_queries":[]
      }
    JSON
  end

  def one_of_two_manual_sections_rummager_json_result(manual_slug)
    <<-JSON.strip_heredoc
      {
        "results":[
          {
            "format":"hmrc_manual_section",
            "link":"/hmrc-internal-manuals/#{manual_slug}/section-1",
            "organisations":[
              {
                "slug":"hm-revenue-customs",
                "title":"HM Revenue & Customs",
                "acronym":"HMRC",
                "organisation_state":"live",
                "link":"/government/organisations/hm-revenue-customs"
              }
            ],
            "public_timestamp":"2015-02-03T16:30:33+00:00",
            "title":"section 1",
            "index":"mainstream",
            "es_score":null,
            "_id":"/hmrc-internal-manuals/#{manual_slug}/section-1",
            "document_type":"hmrc_manual_section"
          }
        ],
        "total":2,
        "start":0,
        "facets":{},
        "suggested_queries":[]
      }
    JSON
  end

  def two_of_two_manual_sections_rummager_json_result(manual_slug)
    <<-JSON.strip_heredoc
      {
        "results":[
          {
            "format":"hmrc_manual_section",
            "link":"/hmrc-internal-manuals/#{manual_slug}/section-2",
            "organisations":[
              {
                "slug":"hm-revenue-customs",
                "title":"HM Revenue & Customs",
                "acronym":"HMRC",
                "organisation_state":"live",
                "link":"/government/organisations/hm-revenue-customs"
              }
            ],
            "public_timestamp":"2015-02-10T15:56:49+00:00",
            "title":"section 2",
            "index":"mainstream",
            "es_score":null,
            "_id":"/hmrc-internal-manuals/#{manual_slug}/section-2",
            "document_type":"hmrc_manual_section"
          }
        ],
        "total":2,
        "start":1,
        "facets":{},
        "suggested_queries":[]
      }
    JSON
  end
end

RSpec.configuration.include(RummagerHelpers)
