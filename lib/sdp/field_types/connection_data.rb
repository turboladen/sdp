require_relative '../field_type'


class SDP
  module FieldTypes
    class ConnectionDataLine < SDP::FieldType
      attr_accessor :network_type
      attr_accessor :address_type
      attr_accessor :connection_address

      def initialize(init_data=nil)
        @network_type = nil
        @address_type = nil
        @connection_address = nil

        @prefix = "c"

        super(init_data) if init_data
      end

      def to_s
        super

        "#{@prefix}=#{@network_type} #{@address_type} #{@connection_address}\r\n"
      end

      def seed
        @network_type = "IN"
        @address_type = "IP4"
        @connection_address = local_ip
      end

      private

      def add_from_string(init_data)
        if init_data.match /^#{@prefix}=/
          add_from_line(init_data)
        else
          add_from_ip(init_data)
        end
      end

      def add_from_ip(ip)
        @network_type = "IN"
        @address_type = connection_address.match(/\d+\./) ? "IP4" : "IP6"
        @connection_address = ip
      end

      def add_from_line(line)
        /c=(?<network_type>\S+) (?<address_type>\S+) (?<address>\S+)/ =~ line
        @network_type = network_type
        @address_type = address_type
        @connection_address = address
      end
    end

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
    class ConnectionData
      attr_reader :lines

      def initialize(connection_data=nil)
        @lines = []
        return unless connection_data

        if connection_data.is_a? String
          connection_data.each_line { |line| add_line(line) }
        elsif connection_data.is_a? Array
          connection_data.each { |line| add_line(line) }
        end
      end

      def add_line(connection_address)
        @lines << ConnectionDataLine.new(connection_address)
      end

      def to_s
        @lines.map(&:to_s).join
      end

      def each
        @lines.each do |line|
          yield line if block_given?
        end
      end
    end
  end
end
