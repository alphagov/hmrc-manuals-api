class SectionsController < ApplicationController
  def update
    validation_errors = JSON::Validator.fully_validate(
      SECTION_SCHEMA,
      section_params,
      validate_schema: true
    )
    if validation_errors.empty?
      render nothing: true, content_type: "application/json", status: 200
    else
      render json: { status: "error", errors: validation_errors }, status: 422
    end
  end

  private
  def section_params
    params.permit(:title)
  end
end
