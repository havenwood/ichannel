require "timeout"
require "redis"
module IChannel
  class Redis < Channel
    def initialize(serializer, options)
      @key = redis_key_from(options)
      @redis = ::Redis.new options
      super serializer
    end
    
    def redis_key_from(options)
      options.delete(:key) || "channel"
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
end
