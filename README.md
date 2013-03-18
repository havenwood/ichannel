__OVERVIEW__


| Project         | ichannel   
|:----------------|:--------------------------------------------------
| Homepage        | https://github.com/robgleeson/ichannel
| Documentation   | http://rubydoc.info/github/robgleeson/ichannel/frames  
| CI              | [![Build Status](https://travis-ci.org/robgleeson/ichannel.png)](https://travis-ci.org/robgleeson/ichannel)
| Author          | Robert Gleeson             


__DESCRIPTION__

ichannel simplifies interprocess communication by providing a bi-directional
channel that can be used to transport ruby objects between processes on the same 
machine. All communication on a channel occurs on a streamed UNIXSocket that a 
channel uses to queues its messages (ruby objects), and also to ensure that 
messages are received in the order they are sent.

__SERIALIZATION__

ichannel relies on serialization when writing and reading from the underlying 
UNIXSocket. A ruby object is serialized before a write, and it is deserialized 
after a read. The choice of serializer is left up to you, though. A serializer 
can be any object that implements `dump` and `load` -- two methods that are 
usually implemented by serializers written in ruby.

__EXAMPLES__

__1.__

A demo of how to pass ruby objects through a channel and also between processes.  
[Marshal](http://rubydoc.info/stdlib/core/Marshal) is the serializer of choice 
in this example: 

```ruby
channel = IChannel.new Marshal
pid = fork do 
  channel.put Process.pid
  channel.put 'Hello!'
end
Process.wait pid
channel.get # => Fixnum
channel.get # => 'Hello!'
```

__2.__

Knowing when a channel is readable can be useful so that you can avoid a
blocking read. This (bad) example demonstrates how to do that:

```ruby
channel = IChannel.new Marshal
pid = fork do
  sleep 3
  channel.put 42
end
until channel.readable?
  sleep 1
  channel.get # => 42
end
```

__3.__

MessagePack doesn't implement `dump` or `load` but a wrapper can be easily
written:

```ruby
module MyMessagePack
  def self.dump(msg)
    MessagePack.pack(msg)
  end

  def self.load(msg)
    MessagePack.unpack(msg)
  end
end
channel = IChannel.new MyMessagePack
```

__PLATFORM SUPPORT__

_supported_

  * CRuby (1.9+)

_unsupported_
  
  * CRuby 1.8
  * MacRuby
  * JRuby
  * Rubinius (support for Rubinius will come sometime in the future).

__INSTALL__

    $ gem install ichannel

__SEE ALSO__
  
  - [ifuture](https://github.com/Havenwood/ifuture)  
    futures built on process forks and ichannel.

__LICENSE__

MIT. See LICENSE.txt.
