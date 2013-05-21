require "timeout"
require "socket"
module IChannel
  class UNIXSocket < Channel
    SEP = '_$_'
    if respond_to? :private_constant
      private_constant :SEP
    end

    def initialize(serializer = Marshal)
      @reader, @writer = ::UNIXSocket.pair :STREAM
      super serializer
    end
  
    def close_channel
      @reader.close
      @writer.close
    end

    def write_to_channel(object, timeout)
      _, writable, _ = IO.select nil, [@writer], nil, timeout
      if writable
        msg = dumped(object)
        writable[0].syswrite "#{msg}#{SEP}"
      else
        raise IOError, 'The channel cannot be written to.'
      end
    end

    def recv_from_channel(timeout)
      readable, _ = IO.select [@reader], nil, nil, timeout
      if readable
        dump = readable[0].readline(SEP).chomp SEP
        @last_msg = msg_from(dump)
      else
        raise Timeout::Error, 'Time out on read (waited for %s second(s))' % [timeout]
      end
    end

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
  end
end
