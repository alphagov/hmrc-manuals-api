class ManualsController < ApplicationController
  before_action :check_content_type_is_json
  before_action :parse_request_body, only: [:update]

  def update
    manual = PublishingAPIManual.new(params[:id], @parsed_request_body)
    begin
      publishing_api_response = manual.save!
      respond_to do |format|
        format.json do
          render json: { govuk_url: manual.govuk_url },
                 status: publishing_api_response.code,
                 location: manual.govuk_url
        end
      end
    rescue ActionController::UnknownFormat
      error :not_acceptable, "Invalid Accept header"
    rescue GdsApi::HTTPConflict => e
      error :conflict, e
    rescue GdsApi::HTTPUnprocessableEntity => e
      error :unprocessable_entity, e
    rescue ValidationError
      error :unprocessable_entity, manual.errors.full_messages
    end
  end
end
