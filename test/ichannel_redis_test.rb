require_relative 'setup'
require_relative 'ichannel_class_test'
class IChannelRedisTest < IChannelTest
  def setup
    serializer = Object.const_get ENV["SERIALIZER"] || "Marshal"
    @channel = IChannel.redis serializer
  end

  def teardown
    @channel.close
  end

  def test_serialization() end
  def test_serialization_in_fork() end
end
