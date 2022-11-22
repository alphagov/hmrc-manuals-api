FRONTEND_BASE_URL = if Rails.env.development?
                      Plek.find("government-frontend")
                    else
                      Plek.website_root
                    end
