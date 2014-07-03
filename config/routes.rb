Rails.application.routes.draw do
  # This strips out Rails' default .json/.xml format file extensions.
  with_options :format => false do |r|
    r.get '/healthcheck', :to => proc { [200, {}, ['OK']] }

    r.put '/hmrc-manuals/:manual_slug', :to => proc { [200, {'Content-Type' => 'application/json'}, ['{ "status": "ok" }']] }
  end
end
