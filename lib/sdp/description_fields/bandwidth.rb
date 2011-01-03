class SDP::DescriptionFields
  class BandwidthField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'b'
      @ruby_type = :bandwidth
      @required = false
      @value = {
        :bandwidth_type => "",    # CT or AS
        :bandwidth => 0
      }

      unless value.nil?
        super
        map_values
      end
    end

    # If a values string was passed in, the parent class broken those up
    # to an Array.  This maps those values to the value Hash.
    def map_values
      @value[:bandwidth_type] = @parsed_values[0]
      @value[:bandwidth]      = @parsed_values[1]
    end

    # Redefining parent method in order to inject a ":" between the two
    # required fields.  A resulting bandwidth string should look like:
    # "b=CT:100", where "CT" and "100" are the two field type values.
    # 
    # @return [String] A String in the form: "b=0\r\n".
    def to_sdp_s
      values = "#{@value[:bandwidth_type]}:#{@value[:bandwidth]}"

      return "#{@sdp_type}=#{values}\r\n"
    end
  end
end
