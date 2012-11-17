require 'socket'
class IChannel
  #
  # @param [#dump,#load}] serializer
  #   Any object that implements dump, & load.
  #   
  def initialize(serializer) 
    @reader, @writer = UNIXSocket.pair Socket::SOCK_DGRAM
    @serializer = serializer 
  end

  #
  # @return [Boolean]
  #   Returns true when the channel is closed.
  #
  def closed?
    @reader.closed? && @writer.closed?
  end

  #
  # Close the channel.
  #
  # @return [Boolean]
  #   Returns true when the channel has been closed.
  #   Returns nil when the channel is already closed.
  #
  def close
    if !@reader.closed? && !@writer.closed?
      !! [@reader.close, @writer.close]
    end
  end

  #
  # Add an object to the channel.
  #
  # @raise [IOError]
  #   When the channel cannot be written to.
  #
  # @param [Object] object
  #   An object to add to the channel.
  #
  def write(object)
    _, writable, _ = IO.select [], [@writer], [], 0.1
    if writable
      @writer.send @serializer.dump(object), 0
    else
      raise IOError, 'The channel cannot be written to.'
    end
  end
  alias_method :put, :write

  #
  # Receive a object from the channel.
  #
  # @raise [IOError]
  #   When the channel cannot be read from.
  #
  # @return [Object]
  #   The object added to the channel.
  #
  def recv
    readable, _ = IO.select [@reader], [], [], 0.1
    if readable
      msg, _ = @reader.recvmsg
      @serializer.load msg
    else
      raise IOError, 'The channel cannot be read from.' 
    end
  end
  alias_method :get, :recv
end
