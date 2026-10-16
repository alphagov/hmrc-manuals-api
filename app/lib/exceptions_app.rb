# Renders errors raised outside of controller rescue_from handlers
class ExceptionsApp
  def self.call(env)
    if ApiPaths.include?(path(env))
      new(env).response
    else
      fallback.call(env)
    end
  end

  def self.path(env)
    env["action_dispatch.original_path"] || env["PATH_INFO"].to_s
  end

  def self.fallback
    @fallback ||= ActionDispatch::PublicExceptions.new(Rails.public_path)
  end

  def initialize(env)
    @env = env
  end

  def response
    [status, { Rack::CONTENT_TYPE => "application/json; charset=utf-8" }, [JSON.generate(envelope)]]
  end

private

  attr_reader :env

  def status
    return 500 if exception.nil?

    ActionDispatch::ExceptionWrapper.new(env, exception).status_code
  end

  def envelope
    errors = status < 500 ? [exception.message] : ["Server error"]
    { status: "error", errors: }
  end

  def exception
    env["action_dispatch.exception"]
  end
end
