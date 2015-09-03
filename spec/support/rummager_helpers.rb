module RummagerHelpers
  def maximal_manual_for_rummager
    {
      'title'              => 'Employment Income Manual',
      'description'        => 'A manual about incoming employment',
      'link'               => '/hmrc-internal-manuals/employment-income-manual',
      'indexable_content'  => nil,
      'organisations'      => ['hm-revenue-customs'],
      'public_timestamp'   => '2014-01-23T00:00:00+01:00',
      'format'             => 'hmrc_manual',
      'latest_change_note' => 'Description of changes in Title of a Section that was changed',
    }
  end

  def maximal_section_for_rummager
    {
      'title'                  => '12345 - A section on a part of employment income',
      'description'            => 'Some description',
      'link'                   => '/hmrc-internal-manuals/employment-income-manual/12345',
      'indexable_content'      => 'I need somebody to love', # Markdown/HTML has been stripped
      'organisations'          => ['hm-revenue-customs'],
      'public_timestamp'       => '2014-01-23T00:00:00+01:00',
      'hmrc_manual_section_id' => '12345',
      'manual'                 => 'hmrc-internal-manuals/employment-income-manual',
      'format'                 => 'hmrc_manual_section',
    }
  end
end

RSpec.configuration.include(RummagerHelpers)
