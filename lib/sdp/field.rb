require_relative '../ext/string_case_conversions'
require_relative '../../lib/ext/symbol_to_ivar'
require_relative 'base'
require_relative 'field_dsl'
require_relative 'parse_error'


class SDP
  class Field < Base
    include SDP::FieldDSL

    # @param [Hash,String] init_data
    def initialize(init_data)
      if init_data.is_a? Hash
        add_from_hash(init_data)
      elsif init_data.is_a? String
        add_from_string(init_data)
      end
    end

    # Defined here, but must be implemented in subclasses.  Should allow for
    # setting a value on the Field by passing in some String.  Allows for Fields
    # to specify different formats of values to add the value.  For example,
    # ConnectionData accepts an IP address, then determines the other values
    # from that; it also allows for passing in all values like from the RFC.
    #
    # @param [String]
    def add_from_string(init_data)
      # Implement in children.
      warn "#add_from_string called on #{self.class} but is not implemented"
    end

    # Allows for passing key/value pairs that correlate to the field value's
    # name and field value's value.
    #
    # @example Origin
    #   o = SDP::Fields::Origin.new
    #   o_hash = { username: "john", session_id: 12345, session_version: 98765,
    #     network_type: "IN", address_type: "IP4" }
    #   o.add_from_hash(o_hash)
    def add_from_hash(init_data)
      init_data.each do |k, v|
        ivar = k.to_s.insert(0, '@').to_sym
        instance_variable_set(ivar, v)
      end
    end

    # Converts the Field to a String.  Defined here so subclassed Fields can use
    # the warnings defined here.
    #
    # @return [String]
    def to_s
      super

      if settings.prefix.nil?
        warn "Calling #to_s on a #{self.class} without a prefix defined"
      end
    end

    # Converts the field to a Hash.
    #
    # @return [Hash] Self as a Hash.
    def to_hash
      values_hash = field_values.inject({}) do |result, value|
        result[value] = instance_variable_get(value.to_ivar)

        result
      end

      { sdp_type => values_hash }
    end

    # All values of the Field that have been set.
    #
    # @return [Array<Symbol>]
    def set_values
      settings.field_values.find_all do |value|
        instance_variable_get(value.to_ivar)
      end
    end

    # The list of requried values defined for the Field type.
    #
    # @return [Array<Symbol>]
    def required_values
      settings.field_values - settings.optional_field_values
    end

    # Returns the list of values that are required but not set.
    #
    # @return [Array<Symbol>]
    def errors
      required_values - set_values
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
  end
end


# Everything below here depends on SDP::Field having been defined already.
Dir["#{File.dirname(__FILE__)}/fields/*.rb"].each { |f| require f }


class SDP
  class Field
    # @param [Symbol] sdp_type The Field type as a snake-case Symbol; i.e.
    #   to create a new SDP::Fields::TimeZoneAdjustments, pass in
    #   +:time_zone_adjustments+.
    # @return [SDP::Field]
    def self.new_from_type(sdp_type)
      SDP::Fields.const_get(sdp_type.to_s.camel_case).new
    end

    # Creates a new Field class that matches the +prefix+.
    #
    # @param [String] prefix The 1-char String that represents a Field.
    # @return [SDP::Field] The SDP::Fields class that matches the prefix.
    def self.new_from_string(string)
      klass = SDP::Fields.constants.find do |field_class|
        klass = SDP::Fields.const_get field_class
        klass.prefix.to_s == string[0]
      end

      SDP::Fields.const_get(klass).new(string)
    end

    # Creates a Field that defines values based on the +hash+.
    #
    # @param [Hash] hash
    # @return [SDP::Field] The SDP::Fields object that matches the hash.
    def self.new_from_hash(hash)
      klass = SDP::Fields.constants.find do |field_class|
        sdp_type = SDP::Fields.const_get(field_class).sdp_type
        hash.keys.first = sdp_type
      end

      SDP::Fields.const_get(klass).new(hash)
    end
  end
end
