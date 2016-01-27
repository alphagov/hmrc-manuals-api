class SectionsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    section = PublishingAPISection.new(params[:manual_id], params[:id], @parsed_request_body)

    begin
      publishing_api_response = section.save!
      respond_to do |format|
        format.json {
          render json: { govuk_url: section.govuk_url },
          status: publishing_api_response.code,
          location: section.govuk_url
        }
      end
    rescue ActionController::UnknownFormat
      render json: { status: "error", errors: "Invalid Accept header" }, status: 406
    rescue ValidationError
      render json: { status: "error", errors: section.errors.full_messages }, status: 422
    end
  end
end
