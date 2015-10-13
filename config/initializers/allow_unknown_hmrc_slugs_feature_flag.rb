if Rails.env.production?
  HMRCManualsAPI::Application.config.allow_unknown_hmrc_manual_slugs = ENV["ALLOW_UNKNOWN_HMRC_MANUAL_SLUGS"].present?
else
  HMRCManualsAPI::Application.config.allow_unknown_hmrc_manual_slugs = true
end
