require 'sdp/description_field'

class SDP::DescriptionFields

  # TODO: Fix to allow a list of adjustment time/offset combos.
  class TimeZonesField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'z'
      @ruby_type = :time_zones
      @required = false

      @value = {
        :adjustment_time => "",
        :offset => ""
      }

      unless value.nil?
        super
        map_values
      end
    end

    # If a values string was passed in, the parent class broken those up
    # to an Array.  This maps those values to the value Hash.
    def map_values
      @value[:adjustment_time]  = @parsed_values[0]
      @value[:offset]           = @parsed_values[1]
    end    
  end
end
