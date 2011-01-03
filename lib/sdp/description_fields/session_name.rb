class SDP::DescriptionFields
  class SessionNameField < SDP::DescriptionField
    def initialize value
      @sdp_type = 's'
      @ruby_type = :session_name
      @required = true
      @value = value.to_s
    end
  end
end
