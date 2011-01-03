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
  end
end
