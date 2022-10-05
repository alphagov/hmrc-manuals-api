FRONTEND_BASE_URL = if Rails.env.development?
                      Plek.new.find("government-frontend")
                    else
                      Plek.new.website_root
                    end
