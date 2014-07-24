class SectionsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    section = Section.new(@parsed_request_body)

    if section.valid?
      render nothing: true, content_type: "application/json", status: 200
    else
      render json: { status: "error", errors: section.errors.full_messages }, status: 422
    end
  end
end
