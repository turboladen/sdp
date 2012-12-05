class SDP
  class FieldType
    def initialize(init_data)
      if init_data.is_a? Hash
        add_from_hash(init_data)
      else
        add_from_string(init_data)
      end
    end

    def to_s
      if instance_variables.any? { |ivar| instance_variable_get(ivar).nil? }
        warn "Calling #to_s on #{self.class} with empty field value(s)."
      end
    end

    def to_hash
      instance_variables.inject({}) do |result, ivar|
        key = ivar.to_s.sub(/@/, '').to_sym
        result[key] = instance_variable_get(ivar) unless key == :prefix
        result
      end
    end

    def seed
      # Implement in children.
      warn "#seed called on #{self.class} but is not implemented"
    end

    protected

    # Gets the local IP address.
    #
    # @return [String] The IP address.
    def local_ip
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end

    def add_from_string(init_data)
      # Implement in children.
      warn "#add_from_string called on #{self.class} but is not implemented"
    end

    def add_from_hash(init_data)
      # Implement in children.
      #warn "#add_from_hash called on #{self.class} but is not implemented"
      init_data.each do |k, v|
        ivar = k.to_s.insert(0, '@').to_sym
        instance_variable_set(ivar, v)
      end
    end
  end
end
