Rails.application.routes.draw do
  # This strips out Rails' default .json/.xml format file extensions.
  with_options :format => false do |r|
    r.get '/', controller: 'root', action: 'index'
    r.get '/readme', controller: 'root', action: 'readme'
    r.get '/healthcheck', :to => proc { [200, {}, ['OK']] }

    # Support POST for PUT URLs as per:
    # https://www.gov.uk/service-manual/making-software/apis.html#use-http-methods-as-tim-intended
    r.post '/hmrc-manuals/:id', controller: "manuals", action: :update
    r.post '/hmrc-manuals/:manual_id/sections/:id', controller: "sections", action: :update

    # We need to override the controller and url helper here because rails is unhappy
    # with the dash in 'hmrc-manuals'.
    r.resources "hmrc-manuals", only: :update, controller: "manuals", as: "manuals" do
      r.resources "sections", only: :update
    end
  end
end
