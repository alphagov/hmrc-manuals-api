class ManualsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    manual = Manual.new(params[:id], @parsed_request_body)
    if manual.valid?
      publishing_api_response = manual.save!
      render json: { govuk_url: manual.publishing_api_manual.govuk_url },
                    status: publishing_api_response.code,
                    location: manual.publishing_api_manual.govuk_url
    else
      render json: { status: "error", errors: manual.errors.full_messages }, status: 422
    end
  end
end
