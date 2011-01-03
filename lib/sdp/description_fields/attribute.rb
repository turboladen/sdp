class SDP::DescriptionFields
  class AttributesField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'a'
      @ruby_type = :attributes
      @required = false
      @value = {
        :attribute => "",
        :value => nil
      }

      unless value.nil?
        super
        map_values
      end
    end

    # If a values string was passed in, the parent class broken those up
    # to an Array.  This maps those values to the value Hash.
    def map_values
      @value[:attribute]  = @parsed_values[0]
      @value[:value]      = @parsed_values[1]
    end

    # Redefining parent method in order to inject a ":" between the two
    # required fields.  A resulting attribute string should look
    # like: "a=rtpmap:99 h263-1998/90000" or "a=recvonly".
    # 
    # @return [String] A String in the form: "v=0\r\n".
    def to_sdp_s
      if @value[:value].nil?
        values = "#{@value[:attribute]}"
      else
        values = "#{@value[:attribute]}:#{@value[:value]}"
      end

      return "#{@sdp_type}=#{values}\r\n"
    end

    # Redefining parent method since the :value value can be nil.
    # 
    # @return [Boolean] true if field values have been populated; false if
    # not.
    def valid?
      @value[:attribute].empty? ? false : true
    end
  end
end
