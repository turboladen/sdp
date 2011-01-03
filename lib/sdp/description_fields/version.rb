class SDP::DescriptionFields
  class VersionField < SDP::DescriptionField
    def initialize value
      @sdp_type = 'v'
      @ruby_type = :version
      @required = true
      @value = value.to_i
    end
  end
end
