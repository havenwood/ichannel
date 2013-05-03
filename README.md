__OVERVIEW__


| Project         | ichannel   
|:----------------|:--------------------------------------------------
| Homepage        | https://github.com/robgleeson/ichannel
| Documentation   | http://rubydoc.info/github/robgleeson/ichannel/frames  
| CI              | [![Build Status](https://travis-ci.org/robgleeson/ichannel.png)](https://travis-ci.org/robgleeson/ichannel)
| Author          | Robert Gleeson             


__DESCRIPTION__

ichannel is a channel for interprocess communication between ruby processes on
the same machine(or network). The basic idea is that you can "put" a ruby object
onto the channel and on the other end(maybe in a different process, or maybe on
a different machine) you can "get" the object from the channel.

The two main modes of transport are a UNIXSocket(streamed) or [redis](https://redis.io).
A unix socket is fast and operates without any external dependencies but it
can't go beyond a single machine. A channel that uses redis can operate between
different machines. And incase you're wondering ichannel uses a 
redis [list](http://redis.io/commands#list).

A ruby object is serialized(on write) and deserialized(on read) when passing
through a channel. A channel can use any serializer that implements the dump and
load methods. The default is [Marshal](http://ruby-doc.org/core-2.0/Marshal.html).

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

A demo of how to use ichannel with Redis:

```ruby
channel = IChannel.redis
channel.put %w(a)

# In another process, far away…
channel = IChannel.redis
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
