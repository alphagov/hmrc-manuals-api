class ManualsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    manual = PublishingAPIManual.new(params[:id], @parsed_request_body)
    begin
      publishing_api_response = manual.save!
      render json: { govuk_url: manual.govuk_url },
                    status: publishing_api_response.code,
                    location: manual.govuk_url
    rescue ValidationError
      render json: { status: "error", errors: manual.errors.full_messages }, status: 422
    end
  end
end
