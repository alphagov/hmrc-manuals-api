FRONTEND_BASE_URL = if Rails.env.development?
  Plek.new.find('manuals-frontend')
else
  Plek.current.website_root
end
