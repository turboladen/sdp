class SDP::DescriptionFields
  class SessionInformationField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'i'
      @ruby_type = :session_information
      @required = false
      @value = ""

      unless value.nil?
        @value = value
      end
    end
  end
end
