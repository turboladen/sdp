require 'etc'
require 'net/ntp'

class SDP::DescriptionFields
  class OriginField < SDP::DescriptionField
    def initialize value
      @sdp_type = 'o'
      @ruby_type = :origin
      @required = true

      ntp = Net::NTP.get
      @value = Hash.new(
        :username => Etc.getlogin,
        :session_id => ntp.receive_timestamp.to_i,
        :session_version => ntp.receive_timestamp.to_i,
        :net_type => :IN,
        :address_type => :IP4,
        :unicast_address => get_local_ip
      )

      super
      map_values
    end

    def map_values
      @value[:username] = @parsed_values[0]
      @value[:session_id] = @parsed_values[1]
      @value[:session_version] = @parsed_values[2]
      @value[:net_type] = @parsed_values[3]
      @value[:address_type] = @parsed_values[4]
      @value[:unicast_address] = @parsed_values[5]
    end
    
    def get_local_ip
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
