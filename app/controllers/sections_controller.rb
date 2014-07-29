class SectionsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    section = Section.new(params[:manual_id], params[:id], @parsed_request_body)

    if section.valid?
      content_store_response = section.save!
      render nothing: true, content_type: "application/json", status: content_store_response.code
    else
      render json: { status: "error", errors: section.errors.full_messages }, status: 422
    end
  end
end
