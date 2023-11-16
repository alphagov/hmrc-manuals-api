HMRCManualsAPI::Application.config.allow_unknown_hmrc_manual_slugs = if Rails.env.production?
                                                                       ENV["ALLOW_UNKNOWN_HMRC_MANUAL_SLUGS"].present?
                                                                     else
                                                                       true
                                                                     end
