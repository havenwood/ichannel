require_relative "ichannel/channel"
require_relative "ichannel/unix_socket"
require_relative "ichannel/redis"
class IChannel
  #
  # @param
  #   (see UNIXSocket#initialize)
  #
  # @return
  #   (see UNIXSocket#initialize)
  #
  def self.unix(serializer = Marshal, options = {})
    IChannel::UNIXSocket.new serializer, options
  end

  #
  # @param
  #   (see Redis#initialize)
  #
  # @return
  #   (see Redis#initialize)
  #
  def self.redis(serializer = Marshal, options = {})
    IChannel::Redis.new serializer, options
  end
end
