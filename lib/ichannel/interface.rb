class IChannel::Interface
  %w(write write! get get! close closed? readable? last_msg).each do |name|
    define_method(name) do |*|
      raise NotImplementedError,
        "#{self.class} does not implement #{name}"
    end
  end
  alias_method :put, :write
  alias_method :put!, :write!
  alias_method :recv, :get
  alias_method :recv!, :get!
end
