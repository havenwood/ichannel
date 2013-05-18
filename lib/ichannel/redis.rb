require "timeout"
require "redis"
class IChannel::Redis < IChannel
  def initialize(serializer, options)
    key = options.delete(:key) || "channel"
    @redis = ::Redis.new options
    
    super serializer, key
  end
    
  def close_channel
    @redis.quit
  end
  
  def write_to_channel(object, timeout)
    Timeout.timeout(timeout) do
      dump = dumped object
      @redis.lpush @key, dump
    end
  end
  
  def recv_from_channel(timeout)
    Timeout.timeout(timeout) do
      while empty?
        sleep 0.01
      end
      dump = @redis.rpop @key
      @last_msg = msg_from dump
    end
  end
  
  def channel_empty?
    @redis.llen(@key).zero?
  end
end
