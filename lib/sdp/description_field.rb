
# Describes an SDP description field.  Field types are defined by
# the RFC 4566 document and can only be from that list.  The class
# ensures that the type passed is in the list.  The class also
# accepts the Ruby symbol or its SDP single-character counterpart.
class SDP::DescriptionField

  attr_reader :sdp_type
  attr_reader :ruby_type
  attr_reader :required
  attr_accessor :value

  # @param [Symbol,String] type The SDP field type to create.
  # @param [Fixnum,String,Hash] value The SDP value(s) to create.
  def initialize(values)
    @parsed_values = parse_values(values)
  end

  # Splits a single-space-delimited String in to separate values to be
  # used by the inherited class.
  #
  # @param [String] values
  # @return [Array]
  def parse_values values
    values.split ' '
  end

  # Takes the current field and its values and turns it in to the field
  # line that would be found in a real SDP description.  This String
  # contains the required \r\n (CRLF or 0x0d0a).
  # 
  # @return [String] A String in the form: "v=0\r\n".
  def to_sdp_s
    if @value.class == String || @value.class == Fixnum
      return "#{@sdp_type}=#{@value.to_s}\r\n"
    else
      values = ""
      @value.each_pair do |k,v|
        values << v.to_s + " "
      end
      
      return "#{@sdp_type}=#{values.chop!}\r\n"
    end
  end

  # Deterines is the field is valid or not based on whether or not its
  # fields have been filled out.
  # 
  # @return [Boolean] true if field values have been populated; false if
  # not.
  def valid?
    if @value.class == String || @value.class == Fixnum
      if @value.nil? || @value.to_s.empty?
        return false
      end
    else
      @value.each_pair do |k,v|
        if v.nil? || v.to_s.empty?
          return false
        end
      end
    end

    true
  end
end