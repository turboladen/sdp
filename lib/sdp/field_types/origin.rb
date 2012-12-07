require_relative '../field'


class SDP
  module FieldTypes

    # @example Build from scratch
    #   o = Origin.new
    #   o.username = "john"
    #   o.session_id = 1
    #   o.session_version = 123
    #   o.network_type = "IN"
    #   o.address_type = "IP4"
    #   o.unicast_address = my-computer.pants.com
    #   o.to_s      # => "o=john 1 123 IN IP4 my-computer.pants.com\r\n"
    #
    # @example Build from String
    #   o = Origin.new "o=john 1 123 IN IP4 my-computer.pants.com\r\n"
    #   o.username        # => "john"
    #   o.session_id      # => 1
    #   o.session_version # => 123
    #   o.network_type    # => "IN"
    #   o.address_type    # => "IP4"
    #   o.unicast_address # => my-computer.pants.com
    #   o.to_s            # => "o=john 1 123 IN IP4 my-computer.pants.com\r\n"
    #
    # @example Build from Hash
    #   origin_hash = {
    #     :username => "Steveloveless", :session_id => 3563684370,
    #     :session_version => 3563684370, :network_type => "IN",
    #     :address_type => "IP4", :unicast_address => "sloveless-mbp.local"
    #   }
    #   o = Origin.new(origin_hash)
    #   o.to_s            # => "o=john 1 123 IN IP4 my-computer.pants.com\r\n"
    class Origin < SDP::Field
      field_value :username
      field_value :session_id
      field_value :session_version
      field_value :network_type
      field_value :address_type
      field_value :unicast_address
      prefix :o

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@username} #{@session_id} #{@session_version} " +
          "#{@network_type} #{@address_type} #{@unicast_address}\r\n"
      end

      def seed
        require 'socket'
        require 'etc'
        require_relative '../../ext/time_ntp'

        @username = Etc.getlogin
        @session_id = Time.now.to_ntp
        @session_version = @session_id
        @network_type = "IN"
        @address_type = "IP4"
        @unicast_address = Socket.gethostname

        self
      end

      private

      def add_from_string(init_data)
        m = init_data.match(/^#{prefix}=(?<u>\S+) (?<i>\S+) (?<v>\S+) (?<n>\S+) (?<t>\S+) (?<a>\S+)/)
        @username = m[:u]
        @session_id = m[:i]
        @session_version = m[:v]
        @network_type = m[:n]
        @address_type = m[:t]
        @unicast_address = m[:a]
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
