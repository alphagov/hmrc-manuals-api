class AssetsController < ApplicationController
  before_action :check_content_type_is_multipart

  def create
    asset = {
      draft: asset_params[:draft].nil? || asset_params[:draft] != "false",
      file: asset_params[:file].tempfile,
    }

    if asset[:draft]
      asset[:auth_bypass_ids] = [SecureRandom.uuid]
      asset[:auth_bypass_ids_expiry] = Time.zone.now + 30.days
    end

    asset_manager_response = Services.asset_manager.create_asset(asset).to_h

    output = {
      _response_info: {
        status: "ok",
      },
      asset_id: get_asset_id_from_url(asset_manager_response["file_url"]),
      content_type: asset_manager_response["content_type"],
      deleted: asset_manager_response["deleted"],
      draft: asset_manager_response["draft"],
      file_url: asset_manager_response["file_url"],
      id: asset_manager_response["id"],
      name: asset_manager_response["name"],
      size: asset_manager_response["size"],
      state: asset_manager_response["state"],
    }

    output[:file_url] = "#{asset_manager_response['file_url']}?token=#{asset[:auth_bypass_ids].first}" if asset[:auth_bypass_ids]
    output[:preview_expiry] = asset[:auth_bypass_ids_expiry].iso8601 if asset[:auth_bypass_ids_expiry]

    respond_to do |format|
      format.json do
        render status: :created, json: output
      end
    end
  rescue ActionController::UnknownFormat
    error :not_acceptable, "Invalid Accept header"
  end

private

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

  def get_asset_id_from_url(url)
    url[/\/media\/(.*)\//, 1]
  end
end
