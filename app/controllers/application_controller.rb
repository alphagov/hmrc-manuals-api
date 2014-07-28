class ApplicationController < ActionController::API
  include GDS::SSO::ControllerMethods

  before_filter :require_signin_permission!

private
  def parse_request_body
    @parsed_request_body = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    message = "Request JSON could not be parsed: #{e.message}"
    render json: { status: "error", errors: [message] }, status: 400
  end
end
