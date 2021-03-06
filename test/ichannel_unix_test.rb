require_relative 'setup'
class IChannelUNIXTest < Test::Unit::TestCase
  def setup
    serializer = Object.const_get ENV["SERIALIZER"] || "Marshal"
    @channel = IChannel.unix serializer
  end

  def teardown
    @channel.close
  end

  def test_interface
    %w(write
    write!
    get
    get!
    close
    closed?
    readable?
    last_msg
    put
    put!
    recv
    recv!).each do |method|
      assert @channel.respond_to? method
    end
  end

  def test_blocking_get
    assert_raises Timeout::Error do
      Timeout.timeout(1) { @channel.get }
    end
  end

  def test_timeout_on_get
    assert_raises Timeout::Error do
      @channel.get! 0.1
    end
  end

  def test_last_msg_after_read
    @channel.put [42]
    @channel.get
    assert_equal [42], @channel.last_msg
  end

  def test_fork
    if RUBY_ENGINE == "jruby"
      skip "jruby does not implement Kernel.fork"
    end
    pid = fork do
      @channel.put [42]
    end
    Process.wait pid
    assert_equal [42], @channel.get
  end

  def test_last_msg
    @channel.put %w(a)
    @channel.put %w(b)
    assert_equal %w(b), @channel.last_msg
  end

  def test_last_msg_cache
    @channel.put %w(a)
    2.times { assert_equal %w(a), @channel.last_msg }
    @channel.close
    assert_equal nil, @channel.last_msg
  end

  def test_bust_last_msg_cache
    @channel.put %w(a)
    assert_equal %w(a), @channel.last_msg
    @channel.put %w(b)
    2.times { assert_equal %w(b), @channel.last_msg }
  end

  def test_put_on_closed_channel
    @channel.close
    assert_raises IOError do
      @channel.put %w(a)
    end
  end

  def test_get_on_closed_channel
    @channel.close
    assert_raises IOError do
      @channel.get
    end
  end

  def test_queued_messages
    @channel.put %w(a)
    @channel.put %w(b)
    assert_equal %w(a), @channel.get
    assert_equal %w(b), @channel.get
  end

  def test_readable_on_populated_channel
    @channel.put %w(a)
    @channel.put %w(b)
    assert @channel.readable?
  end

  def test_readable_on_empty_channel
    @channel.put %w(42)
    @channel.get # discard
    refute @channel.readable?
  end

  def test_readable_on_closed_channel
    @channel.close
    refute @channel.readable?
  end
end
