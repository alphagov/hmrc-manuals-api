require 'rails_helper'
require 'gds_api/test_helpers/content_store'

describe 'manuals resource' do
  include GdsApi::TestHelpers::ContentStore

  it 'confirms update of the manual' do
    stub_default_content_store_put

    put_json '/hmrc-manuals/employment-income-manual', valid_manual

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
    assert_content_store_put_item('/guidance/employment-income-manual', valid_manual_for_content_store)
  end
end
