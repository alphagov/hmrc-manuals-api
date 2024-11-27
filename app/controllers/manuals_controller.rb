class ManualsController < ApplicationController
  before_action :parse_request_body, only: [:update]

  def update
    manual = PublishingAPIManual.new(params[:id], @parsed_request_body)
    begin
      publishing_api_response = manual.save!
      respond_to do |format|
        format.json do
          render json: { govuk_url: manual.govuk_url },
                 status: publishing_api_response.code,
                 location: manual.govuk_url
        end
      end
    rescue ActionController::UnknownFormat
      render json: { status: "error", errors: "Invalid Accept header" }, status: :not_acceptable
    rescue GdsApi::HTTPUnprocessableEntity => e
      render json: { status: "error", errors: e }, status: :unprocessable_entity
    rescue ValidationError
      render json: { status: "error", errors: manual.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
