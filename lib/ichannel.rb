class IChannel
  require 'redis'
  require_relative "ichannel/unix_socket"
  require_relative "ichannel/redis"

  def self.unix(serializer = Marshal, options = {})
    UNIXSocket.new serializer, options
  end

  def self.redis(serializer = Marshal, options = {})
    Redis.new serializer, options
  end
end
