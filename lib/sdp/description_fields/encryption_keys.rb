class SDP::DescriptionFields
  class EncryptionKeysField < SDP::DescriptionField
    def initialize value=nil
      @sdp_type = 'k'
      @ruby_type = :encryption_keys
      @required = false
      @value = {
        :method => "",
        :encryption_key => nil
      }

      unless value.nil?
        super
        map_values
      end
    end

    # If a values string was passed in, the parent class broken those up
    # to an Array.  This maps those values to the value Hash.
    def map_values
      @value[:method]         = @parsed_values[0]
      @value[:encryption_key] = @parsed_values[1]
    end

    # Redefining parent method in order to inject a ":" between the two
    # required fields.  A resulting encryption keys string should look
    # like: "k=clear:mypassword".
    # 
    # @return [String] A String in the form: "v=0\r\n".
    def to_sdp_s
      unless @value[:method].empty? || @value[:encryption_key].nil?
        values = "#{@value[:method]}:#{@value[:encryption_key]}"
      end

      return "#{@sdp_type}=#{values}\r\n"
    end
  end
end
