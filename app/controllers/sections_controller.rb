class SectionsController < ApplicationController
  before_action :check_content_type_is_json
  before_action :parse_request_body, only: [:update]

  def update
    section = PublishingAPISection.new(params[:manual_id], params[:id], @parsed_request_body)

    begin
      publishing_api_response = section.save!
      respond_to do |format|
        format.json do
          render json: { govuk_url: section.govuk_url },
                 status: publishing_api_response.code,
                 location: section.govuk_url
        end
      end
    rescue ActionController::UnknownFormat
      error :not_acceptable, "Invalid Accept header"
    rescue GdsApi::HTTPConflict => e
      error :conflict, e
    rescue GdsApi::HTTPUnprocessableEntity => e
      error :unprocessable_entity, e
    rescue ValidationError
      error :unprocessable_entity, section.errors.full_messages
    end
  end
end
