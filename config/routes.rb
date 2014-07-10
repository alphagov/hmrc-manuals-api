Rails.application.routes.draw do
  # This strips out Rails' default .json/.xml format file extensions.
  with_options :format => false do |r|
    r.get '/healthcheck', :to => proc { [200, {}, ['OK']] }

    # We need to override the controller and url helper here because rails is unhappy
    # with the dash in 'hmrc-manuals'.
    r.resources "hmrc-manuals", only: :update, controller: "manuals", as: "manuals" do
      r.resources "sections", only: :update
    end
  end
end
