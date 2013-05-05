__OVERVIEW__

| Project         | ichannel   
|:----------------|:--------------------------------------------------
| Homepage        | https://github.com/robgleeson/ichannel
| Documentation   | http://rubydoc.info/github/robgleeson/ichannel/frames  
| CI              | [![Build Status](https://travis-ci.org/robgleeson/ichannel.png)](https://travis-ci.org/robgleeson/ichannel)
| Author          | Robert Gleeson             


__DESCRIPTION__

ichannel is a channel for interprocess communication between ruby processes on
the same machine or network. The basic premise is that you can "put" a ruby 
object onto the channel and on the other end(maybe in a different process, 
or maybe on a different machine) you can "get" the object from the channel.
 
__EXAMPLES__

__1.__

A demo of how to pass ruby objects through a channel and also between processes.  
[Marshal](http://rubydoc.info/stdlib/core/Marshal) is the serializer of choice, 
and a streamed UNIXSocket is mode of transport:

```ruby
channel = IChannel.unix Marshal
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
blocking read on the underlying UNIXSocket. This (bad) example demonstrates 
how to do that:

```ruby
channel = IChannel.unix Marshal 
pid = fork do
  sleep 3
  channel.put 42
end
until channel.readable?
  # do something else
end
channel.get # => 42
Process.wait pid
```

__3.__

A demo of a channel sending messages between machines by using
[redis](https://redis.io) as a backend:

```ruby
channel = IChannel.redis Marshal, key: "readme-example"
channel.put %w(a)

# In another process, on another machine, far away…
channel = IChannel.redis Marshal, key: "readme-example"
channel.get # => ["a"]
```

__4.__

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
channel = IChannel.unix MyMessagePack
```

__PLATFORM SUPPORT__

_supported_

  * CRuby (1.9+)  
  * Rubinius (1.9+)
  * JRuby (1.9+ - some tests skipped)  
    JRuby is supported and passes the test suite but it has a few skips.
    Three skips are because jruby does not implement Kernel.fork and one
    looks like a possible bug in JRuby's Marshal when trying to deserialize 
    a channel that uses a unix socket. The other 24 tests pass on jruby, &
    those tests cover both unix sockets & redis.

_unsupported_

  * Any 1.8 implementation  
  * MacRuby

__INSTALL__

If you plan on using redis you'll need to install the 'redis' gem. It's
optional:

    $ gem install redis

And to finish:

    $ gem install ichannel

__SEE ALSO__
  
  - [ifuture](https://github.com/Havenwood/ifuture)  
    futures built on process forks and ichannel.

__LICENSE__

MIT. See LICENSE.txt.
