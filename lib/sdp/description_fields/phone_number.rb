class SDP::DescriptionFields
  class PhoneNumberField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'p'
      @ruby_type = :phone_number
      @required = false
      @value = ""

      unless value.nil?
        @value = value
      end
    end
  end
end
