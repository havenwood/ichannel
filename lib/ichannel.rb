require 'socket'
class IChannel
  #
  # @param [#dump,#load] serializer
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
    unless closed?
      @reader.close
      @writer.close
      true
    end
  end

  #
  # Add an object to the channel.
  #
  # @raise [IOError] 
  #   When the channel is closed.
  #
  # @param [Object] object
  #   An object to add to the channel.
  #
  def write(object)
    write!(object, nil)
  end
  alias_method :put, :write

  #
  # Add an object to the channel.
  #
  # Unlike {#put}, which waits indefinitely until the channel becomes writable,
  # this method will raise an IOError if 0.1 seconds elapse and the channel 
  # remains unwritable.
  #
  # @raise [IOError]
  #   When 0.1 seconds elapse and the channel remains unwritable.
  #
  # @param (see IChannel#put).
  #
  def write!(object, timeout = 0.1)
    if @writer.closed?
      raise IOError, 'The channel cannot be written to (closed).'
    end
    _, writable, _ = IO.select [], [@writer], [], timeout
    if writable
      writable[0].send @serializer.dump(object), 0
    else
      raise IOError, 'The channel cannot be written to.'
    end
  end
  alias_method :put!, :write!

  #
  # Receive a object from the channel.
  #
  # @raise [IOError]
  #   When the channel is closed.
  #
  # @return [Object]
  #   The object read from the channel.
  #   
  def recv
    recv!(nil)
  end
  alias_method :get, :recv

  #
  # Receive a object from the channel.
  #
  # Unlike {#get}, which waits indefinitely until the channel becomes readable, 
  # this method will raise an IOError if 0.1 seconds elapse and the channel 
  # remains unreadable.
  #
  # @raise [IOError]
  #   When 0.1 seconds elapse and the channel remains unreadable.
  #
  # @return [Object]
  #   The object read from the channel.
  #
  def recv!(timeout = 0.1)
    if @reader.closed?
      raise IOError, 'The channel cannot be read from (closed).'
    end
    readable, _ = IO.select [@reader], [], [], timeout
    if readable
      msg, _ = readable[0].recvmsg
      @serializer.load msg
    else
      raise IOError, 'The channel cannot be read from.'
    end
  end
  alias_method :get!, :recv!
end
