require 'sdp/description_field'

class SDP::DescriptionFields
  class RepeatTimesField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'r'
      @ruby_type = :repeat_times
      @required = false
      @value = {
        :repeat_interval => "",
        :active_duration => "",
        :offsets_from_start_time => ""
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

    def map_values
      @value[:repeat_interval]          = @parsed_values[0]
      @value[:active_duration]          = @parsed_values[1]
      @value[:offsets_from_start_time]  = @parsed_values[2]
    end
  end
end
