class IChannel
  require_relative "ichannel/unix_socket"
  def self.unix(adapter_options)
    UNIXSocket.new(adapter_options)
  end

  def self.redis(adapter_options)
    # TODO
  end
end
