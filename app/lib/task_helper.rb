class TaskHelper
  def self.output_error_message(message)
    Rails.logger.debug "ERROR!"
    Rails.logger.debug "  "
    Rails.logger.debug message
  end

  def self.save_and_output(item)
    response = item.save!
    if response.code == 200
      Rails.logger.debug "OK!"
    else
      output_error_message(response.raw_response_body)
    end
  rescue StandardError => e
    output_error_message(e.message)
  end
end
