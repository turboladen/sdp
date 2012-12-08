require_relative '../ext/string_case_conversions'
require_relative 'parse_error'
require_relative 'field_dsl'


class Symbol
  def to_ivar
    "@#{self}".to_sym
  end
end


class SDP
  class Field
    include SDP::FieldDSL

    # @param [Hash,String] init_data
    def initialize(init_data)
      if init_data.is_a? Hash
        add_from_hash(init_data)
      elsif init_data.is_a? String
        add_from_string(init_data)
      end
    end

    def to_s
      unless valid?
        warn "#to_s called on a #{self.class} without required values added: " +
          "#{errors}"
      end

      if self.class.prefix.nil?
        warn "Calling #to_s on a #{self.class} without a prefix defined"
      end
    end

    def set_values
      self.class.field_values.find_all do |value|
        instance_variable_get(value.to_ivar)
      end
    end

    def required_values
      self.class.field_values - self.class.optional_field_values
    end

    def valid?
      errors.empty?
    end

    def errors
      required_values - set_values
    end

    # Returns the name of the lowest level class as a snake-case Symbol.
    #
    # @example
    #   SDP::FieldTypes::TimeZoneAdjustments.sdp_type   # => :time_zone_adjustments
    #
    # @return [Symbol]
    def sdp_type
      self.class.sdp_type
    end

    # Converts the field to a Hash.
    #
    # @return [Hash] Self as a Hash.
    def to_hash
      values_hash = field_values.inject({}) do |result, value|
        result[value] = instance_variable_get(value.to_ivar)

        result
      end

      klass_name = self.class.name.split("::").last
      key = klass_name.snake_case.to_sym

      { key => values_hash }
    end

    # Hook method defined for children to redefine if desired.
    def seed
      # Implement in children.
      warn "#seed called on #{self.class} but is not implemented"
    end

    def field_values
      self.class.field_values ||= []
    end

    def prefix
      self.class.prefix
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
