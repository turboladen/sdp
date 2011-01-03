require 'uri'
require 'sdp/description_field'

class SDP::DescriptionFields
  class UriField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'u'
      @ruby_type = :uri
      @required = false
      @value = ""

      unless value.nil?
        @value = value
      end
    end
  end
end
