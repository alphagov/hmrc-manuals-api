class ManualsController < ApplicationController
  before_filter :parse_request_body, only: [:update]

  def update
    manual = Manual.new(params[:id], @parsed_request_body)
    if manual.valid?
      manual.save!
      render nothing: true, content_type: "application/json", status: 200
    else
      render json: { status: "error", errors: manual.errors.full_messages }, status: 422
    end
  end
end
