FRONTEND_BASE_URL = if Rails.env.development?
                      Plek.new.find("government-frontend")
                    else
                      Plek.current.website_root
                    end
