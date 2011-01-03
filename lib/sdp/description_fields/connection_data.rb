require 'sdp/description_field'

class SDP::DescriptionFields
  class ConnectionDataField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'c'
      @ruby_type = :connection_data
      @required = false

      ntp = Net::NTP.get
      @value = {
        :net_type => :IN,
        :address_type => :IP4,
        :connection_address => get_local_ip
      }

      unless value.nil?
        super
        map_values
      end
    end

    # If a values string was passed in, the parent class broken those up
    # to an Array.  This maps those values to the value Hash.
    def map_values
      @value[:net_type]           = @parsed_values[0]
      @value[:address_type]       = @parsed_values[1]
      @value[:connection_address] = @parsed_values[2]
    end
    
    # Gets current local IP address.
    # 
    # @return [String] The IP address as a String.
    def get_local_ip
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

      UDPSocket.open do |s|
        s.connect '74.125.224.17', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end
  end
end
