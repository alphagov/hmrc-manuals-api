class SectionsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    section = Section.new(params[:manual_id], params[:id], @parsed_request_body)

    if section.valid?
      publishing_api_response = section.save!
      render json: { govuk_url: section.publishing_api_section.govuk_url },
                    content_type: "application/json", status: publishing_api_response.code,
                    location: section.publishing_api_section.govuk_url
    else
      render json: { status: "error", errors: section.errors.full_messages }, status: 422
    end
  end
end
