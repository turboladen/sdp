require_relative '../field'


class SDP
  module FieldTypes

    # @example Build from scratch
    #   c = ConnectionData.new
    #   c.add_line "127.0.0.1"
    #   c.add_line "FF15::101"
    #   c.to_s        # => "c=IN IP4 127.0.0.1\r\nc=IN IP6 FF15::101\r\n"
    #
    # @example Build from String
    #   connection_strings = "c=IN IP4 127.0.0.1\r\nc=IN IP6 FF15::101\r\n"
    #   c = ConnectionData.new(connection_strings)
    #   c.lines       # => [
    #                 #     {
    #                 #       :network_type => "IN",
    #                 #       :connection_address => "127.0.0.1",
    #                 #       :address_type => "IP4",
    #                 #     }, {
    #                 #       :network_type => "IN",
    #                 #       :connection_address => "FF15::101",
    #                 #       :address_type => "IP6",
    #                 #     },
    #                 #   ]
    #   c.to_s        # => "c=IN IP4 127.0.0.1\r\nc=IN IP6 FF15::101\r\n"
    #
    # @example Build from Array
    #   connection_array = [
    #                        {
    #                          :network_type => "IN",
    #                          :connection_address => "127.0.0.1",
    #                          :address_type => "IP4",
    #                        }, {
    #                          :network_type => "IN",
    #                          :connection_address => "FF15::101",
    #                          :address_type => "IP6",
    #                        },
    #                      ]
    #   c = ConnectionData.new(connection_array)
    #   c.to_s        # => "c=IN IP4 127.0.0.1\r\nc=IN IP6 FF15::101\r\n"
    class ConnectionDataLine < SDP::Field
      field_value :network_type
      field_value :address_type
      field_value :connection_address
      prefix :c

      # Allows for initializing using the standard conventions, but also just by
      # giving an IP address.  If an IP address is passed in, it will determine
      # IP4 vs IP6 and set values accordingly.
      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@network_type} #{@address_type} #{@connection_address}\r\n"
      end

      # Seeds +network_type+ as "IN", +address_type+ as "IP4", and
      # +connection_address+ with your local IP address.
      def seed
        @network_type = "IN"
        @address_type = "IP4"
        @connection_address = local_ip
      end

      private

      def add_from_string(init_data)
        if init_data.match /^#{prefix}=/
          add_from_line(init_data)
        else
          add_from_ip(init_data)
        end
      end

      def add_from_ip(ip)
        @network_type = "IN"
        @address_type = ip.match(/\d+\./) ? "IP4" : "IP6"
        @connection_address = ip
      end

      def add_from_line(line)
        m = line.match(/#{prefix}=(?<nettype>\S+) (?<addrtype>\S+) (?<address>\S+)/)
        @network_type = m[:nettype]
        @address_type = m[:addrtype]
        @connection_address = m[:address]
      end
    end
  end
end
