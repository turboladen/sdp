class SDP::DescriptionFields
  class EmailAddressField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'e'
      @ruby_type = :email_address
      @required = false
      @value = ""

      unless value.nil?
        @value = value
      end
    end
  end
end
