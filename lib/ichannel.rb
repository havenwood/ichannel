class IChannel
  require_relative "ichannel/unix_socket"

  def self.unix(options)
    UNIXSocket.new(options)
  end

  def self.redis(options)
    # TODO
  end
end
