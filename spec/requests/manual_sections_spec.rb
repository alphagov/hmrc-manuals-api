require 'rails_helper'
require 'gds_api/test_helpers/content_store'

describe 'manual sections resource' do
  include GdsApi::TestHelpers::ContentStore

  it 'confirms update of the manual section' do
    stub_default_content_store_put

    put_json '/hmrc-manuals/employment-income-manual/sections/12345', maximal_section

    expect(response.status).to eq(200)
    expect(response.headers['Content-Type']).to include('application/json')
    assert_content_store_put_item('/guidance/employment-income-manual/12345', maximal_section_for_content_store)
  end

  it 'handles the content store being unavailable' do
    content_store_isnt_available

    put_json '/hmrc-manuals/employment-income-manual/sections/12345', maximal_section

    expect(response.status).to eq(503)
  end

  it 'handles the content store request timing out' do
    content_store_times_out

    put_json '/hmrc-manuals/employment-income-manual/sections/12345', maximal_section

    expect(response.status).to eq(503)
  end

  it 'handles some other error with the content store' do
    content_store_validation_error

    put_json '/hmrc-manuals/employment-income-manual/sections/12345', maximal_section

    expect(response.status).to eq(500)
  end

private
  def content_store_times_out
    stub_request(:any, /#{GdsApi::TestHelpers::ContentStore::CONTENT_STORE_ENDPOINT}\/.*/).to_timeout
  end

  def content_store_validation_error
    stub_request(:any, /#{GdsApi::TestHelpers::ContentStore::CONTENT_STORE_ENDPOINT}\/.*/).to_return(:status => 422)
  end
end
