__OVERVIEW__


| Project         | ichannel   
|:----------------|:--------------------------------------------------
| Homepage        | https://github.com/robgleeson/ichannel
| Documentation   | http://rubydoc.info/github/robgleeson/ichannel/frames  
| CI              | [![Build Status](https://travis-ci.org/robgleeson/ichannel.png)](https://travis-ci.org/robgleeson/ichannel)
| Author          | Robert Gleeson             


__DESCRIPTION__

ichannel simplifies interprocess communication by providing a bi-directional
channel that can transport ruby objects between processes on the same machine. 
All communication on a channel occurs on a streamed UNIXSocket that a channel
uses to queues its messages (ruby objects), and also to ensure that messages 
are received in the order they are sent.

In order to transport ruby objects through a channel the objects are serialized 
before a write and deserialized after a read. The choice of serializer is left 
up to you. A serializer can be any object that implements `dump` and
`load` -- two methods that are usually implemented by serializers written in
ruby.

__EXAMPLES__

__1.__

A demo of how to pass ruby objects through a channel and also between processes:

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
