Rails.application.routes.draw do
  # This strips out Rails' default .json/.xml format file extensions.
  scope format: false do
    get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
    get "/healthcheck/ready", to: GovukHealthcheck.rack_response

    scope only: :update do
      resources :manuals, path: "hmrc-manuals" do
        resources :sections
      end
    end

    get "/test_timeout", to: lambda { |_env|
      sleep 300
      [200, {}, %w[OK]]
    }

    resources :assets, only: %i[create show destroy update] do
      post "regenerate-access", action: :regenerate_access, on: :member
      post "restore", action: :restore, on: :member
    end
  end
end
