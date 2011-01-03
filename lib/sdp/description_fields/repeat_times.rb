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

    def map_values
      @value[:repeat_interval]          = @parsed_values[0]
      @value[:active_duration]          = @parsed_values[1]
      @value[:offsets_from_start_time]  = @parsed_values[2]
    end
  end
end
