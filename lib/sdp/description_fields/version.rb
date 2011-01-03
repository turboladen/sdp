require 'sdp'

class SDP::DescriptionFields
  class VersionField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'v'
      @ruby_type = :version
      @required = true
      @value = SDP::SDP_VERSION
    end
  end
end
