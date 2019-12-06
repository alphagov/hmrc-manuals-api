require "gds_api/exceptions"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  respond_to :json

  before_action :authenticate_user!
  before_action :check_content_type_header

  rescue_from GdsApi::BaseError do |exception|
    GovukError.notify(exception)
    if (exception.is_a?(GdsApi::HTTPErrorResponse) && (500..599).cover?(exception.code)) ||
        exception.is_a?(GdsApi::TimedOutException)
      message = "Service unavailable"
      render json: { status: "error", errors: [message] }, status: :service_unavailable
    else
      message = "Server error"
      render json: { status: "error", errors: [message] }, status: :internal_server_error
    end
  end

private

  def parse_request_body
    @parsed_request_body = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    message = "Request JSON could not be parsed: #{e.message}"
    render json: { status: "error", errors: [message] }, status: :bad_request
  end

  def check_content_type_header
    if request.headers["Content-Type"] != "application/json"
      render json: { status: "error", errors: "Invalid Content-Type header" }, status: :unsupported_media_type
    end
  end
end
