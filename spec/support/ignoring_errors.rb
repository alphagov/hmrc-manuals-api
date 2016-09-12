module IgnoringError
  def ignoring_error(error_class)
    yield
  rescue error_class
    nil
  end
end

RSpec.configuration.include IgnoringError
