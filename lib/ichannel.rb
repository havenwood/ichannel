class IChannel
  require_relative "ichannel/unix_socket"

  def self.unix(serializer = Marshal, options = {})
    UNIXSocket.new serializer, options
  end

  def self.redis(serializer = Marshal, options = {})
    raise NotImplementedError
  end
end
