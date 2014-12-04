require_relative 'log_request_body_feature_flag.rb'

if Object.const_defined?('LogStasher') && LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    # Mirrors Nginx request logging, e.g GET /path/here HTTP/1.1
    fields[:request] = "#{request.request_method} #{request.fullpath} #{request.headers['SERVER_PROTOCOL']}"
    # Pass request Id to logging
    fields[:govuk_request_id] = request.headers['GOVUK-Request-Id']

    if HMRCManualsAPI::Application.config.log_request_body
      # request.body is a StringIO and may have already been read, so we need to
      # rewind it to read it again (and again after reading it this time):
      request.body.rewind
      fields[:request_body] = request.body.read
      request.body.rewind
    end
  end
end
