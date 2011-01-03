require 'sdp/description_field'

class SDP::DescriptionFields
  class MediaDescriptionField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'm'
      @ruby_type = :media_description
      @required = true
      @value = {
        :media => "",
        :port => "",
        :protocol => "",
        :format => ""
      }

      unless value.nil?
        super
        map_values
      end
    end

    def map_values
      @value[:media] = @parsed_values[0]
      @value[:port] = @parsed_values[1]
      @value[:protocol] = @parsed_values[2]
      @value[:format] = @parsed_values[3]
    end
  end
end
