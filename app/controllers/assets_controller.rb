class AssetsController < ApplicationController
  before_action :check_asset_manager_requests_allowed
  before_action :check_content_type_is_multipart, only: [:create]

  def create
    asset = {
      draft: asset_params[:draft].nil? || asset_params[:draft] != "false",
      file: asset_params[:file].tempfile,
    }

    asset.merge!(asset_auth_params) if asset[:draft]

    begin
      respond_to do |format|
        format.json do
          asset_manager_response = Services.asset_manager.create_asset(asset)
          output = if asset[:draft]
                     formatted_asset_manager_response_for_draft(asset_manager_response, asset)
                   else
                     formatted_asset_manager_response(asset_manager_response)
                   end

          render status: :created, json: output
        end
      end
    rescue ActionController::UnknownFormat
      error :not_acceptable, "Invalid Accept header"
    rescue GdsApi::HTTPPayloadTooLarge
      error :content_too_large, "Content exceeds maximum permitted size"
    rescue GdsApi::HTTPUnprocessableEntity => e
      error :unprocessable_entity, e.message
    end
  end

  def show
    output = formatted_asset_manager_response(Services.asset_manager.asset(params[:id]))

    render json: output
  rescue GdsApi::HTTPNotFound
    error :not_found, "Asset not found"
  rescue GdsApi::HTTPForbidden
    error :forbidden, "Access to asset is forbidden"
  end

  def regenerate_access
    asset_manager_response = Services.asset_manager.update_asset(params[:id], asset_auth_params)
    output = formatted_asset_manager_response_for_draft(asset_manager_response, asset_auth_params)

    render status: :created, json: output
  rescue GdsApi::HTTPNotFound
    error :not_found, "Asset not found"
  rescue GdsApi::HTTPForbidden
    error :forbidden, "Access to asset is forbidden"
  end

private

  def check_asset_manager_requests_allowed
    head :not_implemented unless Rails.application.config.allow_asset_manager_requests
  end

  def check_content_type_is_multipart
    unless request.headers["Content-Type"].match?(/^multipart\/form-data/)
      error :unsupported_media_type, "Invalid Content-Type header"
    end
  end

  def asset_params
    params.require(:asset).permit(
      :file,
      :draft,
    )
  end

  def formatted_asset_manager_response(asset_manager_response)
    asset_manager_response.to_h.merge(
      { asset_id: get_asset_id_from_url(asset_manager_response["file_url"]) },
    )
  end

  def formatted_asset_manager_response_for_draft(asset_manager_response, asset_params)
    token_expiry = Time.zone.now + 30.days
    token = generate_jwt_token(asset_params[:auth_bypass_ids].first, token_expiry)

    formatted_asset_manager_response(asset_manager_response).merge(
      file_url: "#{asset_manager_response['file_url']}?token=#{token}",
      preview_expiry: token_expiry.iso8601,
    )
  end

  def get_asset_id_from_url(url)
    url[/\/media\/(.*)\//, 1]
  end

  def asset_auth_params
    {
      auth_bypass_ids: [SecureRandom.uuid],
    }
  end

  def generate_jwt_token(auth_bypass_id, token_expiry)
    payload = {
      exp: token_expiry.to_i,
      iat: Time.zone.now.to_i,
      sub: auth_bypass_id,
    }
    JWT.encode(payload, Rails.application.config.jwt_auth_secret, "HS256")
  end
end
