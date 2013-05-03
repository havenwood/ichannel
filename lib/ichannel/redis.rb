class IChannel::Redis

  #
  # @param [#dump,#load] serializer
  #   A serializer.
  #
  # @param [Hash] options
  #   A Hash of options to pass onto the redis-rb client.
  #
  # @return [IChannel::Redis]
  #
  def initialize(serializer, options)
    @serializer = serializer
    @key = options.delete(:key) || "channel"
    @redis = ::Redis.new(options)
    @last_msg = nil
    @closed = false
  end

  #
  # @return [Boolean]
  #   Returns true when the channel is closed.
  #
  def closed?
    @closed
  end

  #
  # Close the channel.
  #
  # @return [Boolean]
  #   Returns true when the channel has been closed.
  #
  def close
    unless closed?
      @redis.quit
      @last_msg = nil
      @closed = true
    end
  end

  #
  # Add an object to the channel.
  #
  # @param [Object] object
  #   The object to add to the channel.
  #
  # @raise [IOError]
  #   When the channel is closed.
  #
  # @return
  #   (see Redis#write!)
  #
  def write(object)
    write!(object, nil)
  end
  alias_method :put, :write

  #
  # Add an object to the channel.
  #
  # @param [Object] object
  #   The object to add to the channel.
  #
  # @param [Fixnum] timeout
  #   The amount of time to wait for the write to complete.
  #
  # @raise [IOError]
  #   When the channel is closed.
  #
  # @raise [Timeout::Error]
  #   When the write does not complete in time.
  #
  # @return [void]
  #
  def write!(object, timeout = 0.1)
    if closed?
      raise IOError, 'The channel cannot be written to (closed)'
    end
    Timeout.timeout(timeout) do
      dump = @serializer.dump object
      # TODO: add option in API to name key.
      @redis.lpush @key, dump
    end
  end
  alias_method :put!, :write!

  #
  # Read an object from the channel.
  #
  # @raise [IOError]
  #   When the channel is closed or empty.
  #
  # @return
  #   (see Redis#recv!)
  #
  def recv
    recv! nil
  end
  alias_method :get, :recv

  #
  # @param [Fixnum] timeout
  #   The amount of time to wait for the read to complete.
  #
  # @raise [IOError]
  #   When the channel is closed or empty.
  #
  # @raise [Timeout::Error]
  #   When the read does not complete in time.
  #
  # @return [Object]
  #   The object read from the channel.
  #
  def recv!(timeout = 0.1)
    if closed?
      raise IOError, 'The channel cannot be read from (closed).'
    elsif empty?
      raise IOError, 'The channel cannot be read from (empty).'
    else
      Timeout.timeout(timeout) do
        # TODO: should @last_msg be set here?
        dump = @redis.rpop @key
        @last_msg = @serializer.load dump
      end
    end
  end
  alias_method :get!, :recv!

  #
  # @return [Object]
  #   Returns the last message written to the channel.
  #
  def last_msg
    while readable?
      @last_msg = get
    end
    @last_msg
  end

  #
  # @return [Boolean]
  #   Returns true when the channel is empty.
  #
  def empty?
    @redis.llen(@key) == 0
  end

  #
  # @return [Boolean]
  #   Returns true when the channel is readable.
  #
  def readable?
    !closed? && !empty?
  end
end
