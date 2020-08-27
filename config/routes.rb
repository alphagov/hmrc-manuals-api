Rails.application.routes.draw do
  # This strips out Rails' default .json/.xml format file extensions.
  scope format: false do
    get "/", to: "root#index"
    get "/documentation", to: "root#documentation"
    get "/readme", to: redirect("/documentation")
    get "/healthcheck", to: proc { [200, {}, %w[OK]] }

    scope only: :update do
      resources :manuals, path: "hmrc-manuals" do
        resources :sections
      end
    end
  end
end
