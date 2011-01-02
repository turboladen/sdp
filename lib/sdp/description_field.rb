
# Describes an SDP description field.  Field types are defined by
# the RFC 4566 document and can only be from that list.  The class
# ensures that the type passed is in the list.  The class also
# accepts the Ruby symbol or its SDP single-character counterpart.
class SDP::DescriptionField
  include SDP::Types

  TYPE_PROPERTIES = [ 
    { :sdp_type => 'v', :ruby_type => :version, :required => true, :klass => Version },
    { :sdp_type => 'o', :ruby_type => :origin, :required => true, :klass => Origin },
    { :sdp_type => 's', :ruby_type => :session_name, :required => true, :klass => SessionName },
    { :sdp_type => 't', :ruby_type => :timing, :required => true, :klass => Timing },
    { :sdp_type => 'm', :ruby_type => :media_description, :required => true, :klass => MediaDescription }
  ]

  attr_reader :sdp_type
  attr_reader :ruby_type
  attr_reader :required
  attr_reader :klass
  attr_accessor :value

  # @param [Symbol,String] type The SDP field type to create.
  # @param [Fixnum,String,Hash] value The SDP value(s) to create.
  def initialize(type, value=nil)
puts "type: #{type}"
    get_properties_from_type(type)
    @value = value_to_ruby(value)
puts "@value: #{@value}"
  end

  def get_properties_from_type type
    TYPE_PROPERTIES.each do |field|
      if type == field[:sdp_type] || type == field[:ruby_type]
        @sdp_type = field[:sdp_type]
        @ruby_type = field[:ruby_type].to_sym
        @required = field[:required]
        @klass = field[:klass]
      end
    end
  end

  def value_to_ruby value
    if value.nil? || value == ""
      begin
        puts "@klass = #{@klass}"
        return @klass.new
      rescue NoMethodError
        return value
      end
    end

    value
  end

  def to_sdp_s
    if @value.class == String || @value.class == Fixnum
      return "#{@sdp_type}=#{@value.to_s}\r\n"
    else
      values = ""
      @value.each do |v|
        values << v.to_s + " "
      end
      
      return "#{@sdp_type}=#{values}\r\n"
    end
  end
end