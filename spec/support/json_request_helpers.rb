module JSONRequestHelper
  def put_json(path, attrs, headers = {})
    default_headers = {
      "CONTENT_TYPE" => "application/json",
      'HTTP_ACCEPT' => 'application/json',
      'HTTP_AUTHORIZATION' => 'Bearer 12345678'
    }
    put path, attrs.to_json, default_headers.merge(headers)
  end

  def put_json_with_invalid_headers(path, attrs, headers = {})
    wrong_headers = {
      'CONTENT_TYPE' => 'text/plain',
      'HTTP_ACCEPT' => 'text/plain',
      'HTTP_AUTHORIZATION' => 'Bearer 12345678'
    }
    put path, attrs.to_json, wrong_headers.merge(headers)
  end

  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configuration.include JSONRequestHelper, :type => :request
