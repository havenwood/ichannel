require 'socket'
class IChannel
  SEP = '_$_'
  private_constant :SEP

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
  # Unlike {#write}, which waits indefinitely until the channel becomes writable,
  # this method will raise an IOError when _timeout_ seconds elapse and
  # the channel remains unwritable.
  #
  # @param
  #   (see IChannel#write)
  #
  # @param [Numeric] timeout
  #   The number of seconds to wait for the channel to become writable.
  #
  # @raise (see IChannel#write)
  #
  # @raise [IOError]
  #   When _timeout_ seconds elapse & the channel remains unwritable.
  #
  def write!(object, timeout = 0.1)
    if @writer.closed?
      raise IOError, 'The channel cannot be written to (closed).'
    end
    _, writable, _ = IO.select nil, [@writer], nil, timeout
    if writable
      serialized = @serializer.dump(object)
      writable[0].syswrite "#{serialized}#{SEP}"
    else
      raise IOError, 'The channel cannot be written to.'
    end
  end
  alias_method :put!, :write!

  #
  # Receive an object from the channel.
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
  # Receive an object from the channel.
  #
  # Unlike {#recv}, which waits indefinitely until the channel becomes readable,
  # this method will raise an IOError when _timeout_ seconds elapse and the
  # channel remains unreadable.
  #
  # @param [Numeric] timeout
  #   The number of seconds to wait for the channel to become readable.
  #
  # @raise [IOError]
  #   (see IChannel#recv)
  #
  # @raise [IOError]
  #   When _timeout_ seconds elapse & the channel remains unreadable.
  #
  # @return [Object]
  #   The object read from the channel.
  #
  def recv!(timeout = 0.1)
    if @reader.closed?
      raise IOError, 'The channel cannot be read from (closed).'
    end
    readable, _ = IO.select [@reader], nil, nil, timeout
    if readable
      msg = readable[0].readline(SEP).chomp(SEP)
      @serializer.load msg
    else
      raise IOError, 'The channel cannot be read from.'
    end
  end
  alias_method :get!, :recv!

  #
  # @return [Boolean]
  #   Returns true when the channel is readable.
  #
  def readable?
    if @reader.closed?
      false
    else
      readable, _ = IO.select [@reader], nil, nil, 0
      !! readable
    end
  end
end
