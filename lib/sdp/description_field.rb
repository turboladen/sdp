require 'sdp'

# Describes an SDP description field.  Field types are defined by
# the RFC 4566 document and can only be from that list.  The class
# ensures that the type passed is in the list.  The class also
# accepts the Ruby symbol or its SDP single-character counterpart.
class SDP::DescriptionField

  attr_reader :sdp_type
  attr_reader :ruby_type
  attr_reader :required
  attr_accessor :value

  # @param [Fixnum,String,Hash] value The SDP value(s) to create.
  def initialize(values)
    @parsed_values = parse_values(values)
  end

  # Redefines value assingment to allow for changing parameters separately.
  #
  # @param [Hash] new_value Key must be an existing @value key or pair.
  def value=(new_value)
    if new_value.class == Hash
      begin
        new_value.each_key do |key|
          unless @value.has_key?(key)
            raise SDP::RuntimeError, "Invalid key: #{key} for class #{self.class}"
          end
        end
      rescue SDP::RuntimeError => ex
        puts ex.message
        raise
      end

      @value.each_pair do |k,v|
        if new_value.has_key?(k)
          @value[k] = new_value[k]
        end
      end
=begin
    elsif new_value.class == String
      @value = new_value and return unless new_value =~ /\s/
#      new_values = parse_values(new_value)
puts "new_value: #{new_value}"
#puts "new_values: #{new_values}"
#puts "size: #{new_values.size}"
@value = new_value
#      if new_values.length == 1
#        @value = new_values.first 
#      else
#        map_values(new_values)
#      end
=end
    else
      @value = new_value
    end
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
  # @todo For Ruby 1.8 this can return a String with values that are out
  # of order, due to lack of Hash ordering.  This needs to be fixed.
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
    
  # Gets current local IP address.
  # 
  # @return [String] The IP address as a String.
  def get_local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect '74.125.224.17', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end
end