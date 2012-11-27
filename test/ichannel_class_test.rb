require_relative 'setup'
class IChannelTest < Test::Unit::TestCase
  def setup
    @channel = IChannel.new [YAML, Marshal, JSON].sample
  end

  def teardown
    @channel.close
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
      @channel.put %w(b)
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

  def test_empty_on_empty_channel
    assert @channel.empty?
  end

  def test_empty_on_populated_channel
    @channel.put %w(a)
    refute @channel.empty?
  end

  def test_empty_on_emptied_channel
    @channel.put %w(a)
    @channel.get 
    assert @channel.empty?
  end

  def test_empty_on_closed_channel
    @channel.put %w(a)
    @channel.close
    assert @channel.empty?
  end
end
