require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

describe 'manuals resource' do
  include GdsApi::TestHelpers::PublishingApi

  it 'confirms update of the manual' do
    stub_default_publishing_api_put

    put_json '/hmrc-manuals/employment-income-manual', maximal_manual

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
    assert_publishing_api_put_item('/guidance/employment-income-manual', maximal_manual_for_publishing_api)
    expect(response.headers['Location']).to include('/guidance/employment-income-manual')
    expect(response.body).to include('/guidance/employment-income-manual')
  end

  it 'handles the content store being unavailable' do
    publishing_api_isnt_available

    put_json '/hmrc-manuals/employment-income-manual', maximal_manual

    expect(response.status).to eq(503)
  end
end
