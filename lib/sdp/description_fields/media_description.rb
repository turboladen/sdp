class SDP::DescriptionFields
  class MediaDescriptionField < SDP::DescriptionField
    def initialize value
      @sdp_type = 'm'
      @ruby_type = :media_description
      @required = true
      @value = Hash.new(:media => "", :port => "", :protocol => "",
        :format => "")

      super
      map_values
    end

    def map_values
      @value[:media] = @parsed_values[0]
      @value[:port] = @parsed_values[1]
      @value[:protocol] = @parsed_values[2]
      @value[:format] = @parsed_values[3]
    end
  end
end
