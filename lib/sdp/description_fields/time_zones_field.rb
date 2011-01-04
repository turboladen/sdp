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

    # Redefines value assingment to allow for changing parameters separately.
    #
    # @param [Hash] new_value Key must be an existing @value key or pair.
    def value=(new_value)
      @value.each_pair do |k,v|
        if new_value.has_key?(k)
          @value[k] = new_value[k]
        end
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
