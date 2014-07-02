Rails.application.routes.draw do
  get '/healthcheck', :to => proc { [200, {}, ['OK']] }

  put '/hmrc-manuals/:manual_slug', :to => proc { [200, {'Content-Type' => 'application/json'}, ['{ "status": "ok" }']] }
end
