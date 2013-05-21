require_relative "ichannel/channel"
require_relative "ichannel/unix_socket"
require_relative "ichannel/redis"
UnknownTransporter = Class.new StandardError
module IChannel
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
  
  def self.new(transporter, serializer = Marshal, options = {})
    if IChannel.respond_to? transporter
      IChannel.send transporter
    else
      raise UnknownTransporter, 'Allowed transporters are :redis or :unix.'
    end
  end
end
