module RummagerHelpers
  def maximal_manual_for_rummager
    {
      'title'             => 'Employment Income Manual',
      'description'       => 'A manual about incoming employment',
      'link'              => 'guidance/employment-income-manual',
      'indexable_content' => nil,
      'organisations'     => ['hm-revenue-customs'],
      'last_update'       => '2014-01-23T00:00:00+01:00',
    }
  end

  def maximal_section_for_rummager
    {
      'title'                  => 'HMRC Manuals: 12345 - A section on a part of employment income',
      'description'            => 'Some description',
      'link'                   => 'guidance/employment-income-manual/12345',
      'indexable_content'      => 'I need somebody to love', # Markdown/HTML has been stripped
      'organisations'          => ['hm-revenue-customs'],
      'last_update'            => '2014-01-23T00:00:00+01:00',
      'hmrc_manual_section_id' => '12345',
      'manual'                 => 'guidance/employment-income-manual',
    }
  end
end

RSpec.configuration.include(RummagerHelpers)
