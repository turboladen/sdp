require_relative '../field'


class SDP
  module FieldTypes
    class Attribute < SDP::Field
      field_value :attribute
      field_value :value, true
      prefix :a

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        s = "#{prefix}=#{@attribute}"
        s << ":#{@value}" if @value
        s << "\r\n"

        s
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<attrib>\S+)( :(?<value>[^\r\n]+))?/)
        @attribute = match[:attrib]
        @attribute.force_encoding("US-ASCII")

        if match[:value]
          @value = match[:value]
        end
      end
    end
  end
end