Rails.application.routes.draw do
  # This strips out Rails' default .json/.xml format file extensions.
  scope format: false do
    get "/", to: "root#index"
    get "/documentation", to: "root#documentation"
    get "/readme", to: redirect("/documentation")

    get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
    get "/healthcheck/ready", to: GovukHealthcheck.rack_response

    scope only: :update do
      resources :manuals, path: "hmrc-manuals" do
        resources :sections
      end
    end
  end
end
