require_relative 'setup'
require_relative 'ichannel_unix_test'
class IChannelRedisTest < IChannelUNIXTest
  def setup
    serializer = Object.const_get ENV["SERIALIZER"] || "Marshal"
    @channel = IChannel.redis serializer
  end

  def teardown
    key = @channel.instance_variable_get :@key
    @channel.instance_variable_get(:@redis).del(key)
    @channel.close
  end

  def test_serialization() end
  def test_serialization_in_fork() end
end
