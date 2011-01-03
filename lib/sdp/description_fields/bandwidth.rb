class SDP::DescriptionFields
  class BandwidthField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'b'
      @ruby_type = :bandwidth
      @required = false
      @value = ""

      unless value.nil?
        @value = value
      end
    end
  end
end
