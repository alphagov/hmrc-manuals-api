require "ostruct"

class User < OpenStruct
  include GDS::SSO::User

  def clear_remotely_signed_out!; end

  def self.where(_args)
    []
  end

  # needed only to appease the :mock_gds_sso strategy
  def self.first
    new
  end

  def save!; end

  # needed only to appease the :mock_gds_sso strategy
  def update_attribute(key, value)
    send("#{key}=", value)
  end

  def self.create!(args)
    new(args)
  end
end
