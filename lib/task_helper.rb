class TaskHelper
  def self.output_error_message(message)
    puts "ERROR!"
    print "  "
    puts message
  end

  def self.save_and_output(item)
    response = item.save!
    if response.code == 200
      puts "OK!"
    else
      output_error_message(response.raw_response_body)
    end
  rescue => e
    output_error_message(e.message)
  end
end
