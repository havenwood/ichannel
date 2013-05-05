module IChannel
  require_relative "ichannel/unix_socket"

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
    unless defined?(IChannel::Redis)
      require_relative "ichannel/redis"
    end
    IChannel::Redis.new serializer, options
  end
end
