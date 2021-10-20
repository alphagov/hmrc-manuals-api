class ManualsController < ApplicationController
  before_action :parse_request_body, only: [:update]

  def update
    manual = PublishingAPIManual.new(params[:id], @parsed_request_body)
    begin
      publishing_api_response = manual.save!
      respond_to do |format|
        format.json do
          render json: { govuk_url: manual.govuk_url },
                 status: "200",
                 location: "/foo"
        end
      end
    rescue ActionController::UnknownFormat
      render json: { status: "error", errors: "Invalid Accept header" }, status: :not_acceptable
    rescue ValidationError
      render json: { status: "error", errors: manual.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
