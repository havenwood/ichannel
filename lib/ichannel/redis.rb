class IChannel::Redis
  def initialize(serializer, options)
    @serializer = serializer
    @redis = ::Redis.new(options)
    @last_msg = nil
    @closed = false
  end

  def closed?
    @closed
  end

  def close
    unless closed?
      @redis.quit
      @last_msg = nil
      @closed = true
    end
  end

  def write(object)
    write!(object, nil)
  end
  alias_method :put, :write

  def write!(object, timeout = 0.1)
    if closed?
      raise IOError, 'The channel cannot be written to (closed)'
    end
    Timeout.timeout(timeout) do
      dump = @serializer.dump object
      # TODO: add option in API to name key.
      @redis.lpush "channel", dump
    end
  end
  alias_method :put!, :write!

  def recv
    recv! nil
  end
  alias_method :get, :recv

  def recv!(timeout = 0.1)
    if closed?
      raise IOError, 'The channel cannot be read from (closed).'
    elsif empty?
      raise IOError, 'The channel cannot be read from (empty).'
    else
      Timeout.timeout(timeout) do
        # TODO: should @last_msg be set here?
        dump = @redis.rpop "channel"
        @serializer.load dump
      end
    end
  end
  alias_method :get!, :recv!

  def last_msg
    while readable?
      @last_msg = get
    end
    @last_msg
  end

  def empty?
    @redis.llen("channel") == 0
  end

  def readable?
    !closed? && !empty?
  end
end
