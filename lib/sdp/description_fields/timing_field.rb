require 'net/ntp'
require 'sdp/description_field'

class SDP::DescriptionFields
  class TimingField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 't'
      @ruby_type = :timing
      @required = true
      ntp = Net::NTP.get
      @value = {
        :start_time => ntp.receive_timestamp.to_i,
        :stop_time => ntp.receive_timestamp.to_i
      }

      unless value.nil?
        super
        map_values
      end
    end

    def map_values
      @value[:start_time] = @parsed_values[0]
      @value[:stop_time] = @parsed_values[1]
    end
  end
end
