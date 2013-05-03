module IChannel
  require 'redis'
  require_relative "ichannel/unix_socket"
  require_relative "ichannel/redis"

  #
  # @param
  #   (see UNIXSocket#initialize)
  #
  # @return
  #   (see UNIXSocket#initialize)
  #
  def self.unix(serializer = Marshal, options = {})
    UNIXSocket.new serializer, options
  end

  #
  # @param
  #   (see Redis#initialize)
  #
  # @return
  #   (see Redis#initialize)
  #
  def self.redis(serializer = Marshal, options = {})
    unless defined?(::Redis)
      require 'redis'
    end
    Redis.new serializer, options
  end
end
