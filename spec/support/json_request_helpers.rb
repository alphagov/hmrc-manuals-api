module JSONRequestHelper
  def post_multipart(path, attrs, headers = {})
    default_headers = {
      "HTTP_ACCEPT" => "application/json",
      "HTTP_AUTHORIZATION" => "Bearer 12345678",
      "CONTENT_TYPE" => "multipart/form-data",
    }

    post path, params: attrs, headers: default_headers.merge(headers)
  end

  def put_multipart(path, attrs, headers = {})
    default_headers = {
      "HTTP_ACCEPT" => "application/json",
      "HTTP_AUTHORIZATION" => "Bearer 12345678",
      "CONTENT_TYPE" => "multipart/form-data",
    }

    put path, params: attrs, headers: default_headers.merge(headers)
  end

  def put_json(path, attrs, headers = {})
    default_headers = {
      "CONTENT_TYPE" => "application/json",
      "HTTP_ACCEPT" => "application/json",
      "HTTP_AUTHORIZATION" => "Bearer 12345678",
    }

    put path, params: attrs.to_json, headers: default_headers.merge(headers)
  end

  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configuration.include JSONRequestHelper, type: :request
