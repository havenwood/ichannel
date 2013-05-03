require 'socket'
module IChannel
  class UNIXSocket
    SEP = '_$_'
    if respond_to? :private_constant
      private_constant :SEP
    end

    #
    # @param [#dump,#load] serializer
    #   Any object that implements dump, & load.
    #
    # @return [IChannel::UNIXSocket]
    #
    def initialize(serializer = Marshal, adapter_options)
      @serializer = serializer
      @last_msg = nil
      @reader, @writer = ::UNIXSocket.pair :STREAM
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
    #
    def close
      unless closed?
        @reader.close
        @writer.close
        @last_msg = nil
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
        msg = @serializer.dump(object)
        writable[0].syswrite "#{msg}#{SEP}"
      else
        raise IOError, 'The channel cannot be written to.'
      end
    end
    alias_method :put!, :write!

    #
    # Reads the last message written to the channel by reading until the channel
    # is empty. The last message is cached and reset to nil on call to {#close}.
    #
    # @return [Object]
    #   Returns the last message to be written to the channel.
    #
    def last_msg
      while readable?
        @last_msg = get
      end
      @last_msg
    end

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
        msg = readable[0].readline(SEP).chomp SEP
        @last_msg = @serializer.load msg
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
      if closed?
        false
      else
        readable, _ = IO.select [@reader], nil, nil, 0
        !! readable
      end
    end

    # @api private
    def marshal_load(array)
      @serializer, reader, writer, @last_msg = array
      @reader = ::UNIXSocket.for_fd(reader)
      @writer = ::UNIXSocket.for_fd(writer)
    end

    # @api private
    def marshal_dump
      [@serializer, @reader.to_i, @writer.to_i, @last_msg]
    end
  end
end
