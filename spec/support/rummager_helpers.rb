module RummagerHelpers
  def stub_any_rummager_post
    stub_request(:post, %r{#{Plek.new.find('search')}/documents})
  end

  def assert_rummager_posted_item(attributes)
    url = Plek.new.find('search') + "/documents"
    assert_requested(:post, url) do |req|
      data = JSON.parse(req.body)
      attributes.to_a.all? do |key, value|
        data[key.to_s] == value
      end
    end
  end

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
end

RSpec.configuration.include(RummagerHelpers)
