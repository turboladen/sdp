require_relative '../ext/string_snake_case'


class Symbol
  def to_ivar
    "@#{self}".to_sym
  end
end


class SDP
  class Field
    class << self
      def field_value(value)
        raise "value must be a Symbol" unless value.is_a? Symbol

        @@field_values ||= []
        @@field_values << value

        define_method value do
          instance_variable_get("@#{value}".to_sym)
        end

        define_method "#{value}=" do |new_value|
          instance_variable_set("@#{value}".to_sym, new_value)
        end
      end

      def field_values
        @@field_values
      end

      def prefix(char=nil)
        return @@prefix if char.nil?
        raise "Can't change prefix after it has been set" if defined? @@prefix

        @@prefix = char
      end
    end


    def initialize(init_data)
      if init_data.is_a? Hash
        add_from_hash(init_data)
      else
        add_from_string(init_data)
      end
    end

    def to_s
      nil_values = @@field_values.any? do |v|
        instance_variable_get(v.to_ivar).nil?
      end

      if nil_values
        warn "Calling #to_s on #{self.class} with empty field value(s)"
      end

      if @@prefix.nil?
        warn "Calling #to_s on #{self.class} without a prefix defined"
      end
    end

    def to_hash
      values_hash = field_values.inject({}) do |result, value|
        result[value] = instance_variable_get(value.to_ivar)

        result
      end

      klass_name = self.class.name.split("::").last
      key = klass_name.snake_case.to_sym

      { key => values_hash }
    end

    def seed
      # Implement in children.
      warn "#seed called on #{self.class} but is not implemented"
    end

    def field_values
      @@field_values ||= []
    end

    def prefix
      @@prefix
    end

    # This custom redefinition of #inspect is needed because of the #to_s
    # definition.
    #
    # @return [String]
    def inspect
      me = "#<#{self.class.name}:0x#{self.object_id.to_s(16)}"

      ivars = self.instance_variables.map do |variable|
        "#{variable}=#{instance_variable_get(variable).inspect}"
      end.join(' ')

      me << " #{ivars} " unless ivars.empty?
      me << ">"

      me
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
      init_data.each do |k, v|
        ivar = k.to_s.insert(0, '@').to_sym
        instance_variable_set(ivar, v)
      end
    end
  end
end
