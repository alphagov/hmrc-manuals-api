require 'json'

module JSONRequestHelper
  def put_json(path, attrs, headers = {})
    put path, attrs.to_json, {"CONTENT_TYPE" => "application/json"}.merge(headers)
  end

  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configuration.include JSONRequestHelper, :type => :request
