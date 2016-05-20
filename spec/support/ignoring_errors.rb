module IgnoringError
  def ignoring_error(error_class, &block)
    block.call
  rescue error_class
    nil
  end
end

RSpec.configuration.include IgnoringError
