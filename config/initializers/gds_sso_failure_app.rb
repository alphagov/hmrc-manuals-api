require "gds-sso/failure_app"

# Render API auth errors in the documented error envelope
module AssetsErrorEnvelopeFailureApp
  def api_unauthorized(message, bearer_error)
    attempted_path = request.env.dig("warden.options", :attempted_path) || request.path

    return super unless ApiPaths.include?(attempted_path)

    headers["WWW-Authenticate"] = %(Bearer error="#{bearer_error}")
    render json: { status: "error", errors: [message] }, status: :unauthorized
  end
end

GDS::SSO::FailureApp.prepend(AssetsErrorEnvelopeFailureApp)
