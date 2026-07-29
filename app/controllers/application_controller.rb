require "gds_api/exceptions"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  respond_to :json

  skip_forgery_protection

  before_action :authenticate_user!

  rescue_from GdsApi::BaseError do |exception|
    GovukError.notify(exception)
    if (exception.is_a?(GdsApi::HTTPErrorResponse) && (500..599).cover?(exception.code)) ||
        exception.is_a?(GdsApi::TimedOutException)
      message = "Service unavailable"
      error :service_unavailable, [message]
    else
      message = "Server error"
      error :internal_server_error, [message]
    end
  end

private

  def parse_request_body
    @parsed_request_body = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    message = "Request JSON could not be parsed: #{e.message}"
    error :bad_request, [message]
  end

  def check_content_type_is_json
    if request.headers["Content-Type"] != "application/json"
      error :unsupported_media_type, "Invalid Content-Type header"
    end
  end

  def error(status, errors)
    render json: { status: "error", errors: }, status:
  end
end
