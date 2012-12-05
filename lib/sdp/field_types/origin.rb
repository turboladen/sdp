require_relative '../field_type'


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
    class Origin < SDP::FieldType
      attr_accessor :username
      attr_accessor :session_id
      attr_accessor :session_version
      attr_accessor :network_type
      attr_accessor :address_type
      attr_accessor :unicast_address

      def initialize(init_data=nil)
        @username = nil
        @session_id = nil
        @session_version = nil
        @network_type = nil
        @address_type = nil
        @unicast_address = nil

        @prefix = "o"

        super(init_data) if init_data
      end

      def to_s
        super

        "#{@prefix}=#{@username} #{@session_id} #{@session_version} " +
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
        /o=(?<u>\S+) (?<i>\S+) (?<v>\S+) (?<n>\S+) (?<t>\S+) (?<a>\S+)/ =~ init_data
        @username = u
        @session_id = i
        @session_version = v
        @network_type = n
        @address_type = t
        @unicast_address = a
      end
    end
  end
end
