require_relative 'setup'
class IChannelTest < Test::Unit::TestCase
  def setup
    serializer = Object.const_get ENV["SERIALIZER"] || "Marshal"
    @channel = IChannel.unix serializer: serializer
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

  def test_put_and_get
    pid = fork do
      @channel.put %w(a b c)
    end
    Process.wait pid
    assert_equal %w(a b c), @channel.get
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
    pid = fork do
      @channel.put %w(a)
      @channel.put %w(b)
    end
    Process.wait pid
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
