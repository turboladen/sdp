require 'sdp/description_field'

class SDP::DescriptionFields
  class SessionNameField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 's'
      @ruby_type = :session_name
      @required = true
      @value = " "

      unless value.nil?
        @value = value
      end
    end

    # If a values string was passed in, the parent class broken those up
    # to an Array.  This maps those values to the value Hash.
    def map_values
      @value = @parsed_values
    end
  end
end
