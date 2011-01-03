
# Describes an SDP description field.  Field types are defined by
# the RFC 4566 document and can only be from that list.  The class
# ensures that the type passed is in the list.  The class also
# accepts the Ruby symbol or its SDP single-character counterpart.
class SDP::DescriptionField

  attr_reader :sdp_type
  attr_reader :ruby_type
  attr_reader :required
  attr_reader :klass
  attr_accessor :value

  # @param [Symbol,String] type The SDP field type to create.
  # @param [Fixnum,String,Hash] value The SDP value(s) to create.
  def initialize(value)
    @parsed_values = parse_values(value)
  end

  def parse_values value
    values = value.split ' '
  end

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
end