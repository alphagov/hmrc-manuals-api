class SectionsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    validation_errors = JSON::Validator.fully_validate(
      SECTION_SCHEMA,
      @parsed_request_body,
      validate_schema: true
    )
    if validation_errors.empty?
      render nothing: true, content_type: "application/json", status: 200
    else
      render json: { status: "error", errors: validation_errors }, status: 422
    end
  end
end
