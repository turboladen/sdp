require_relative '../field'
require_relative '../version'


class SDP
  module Fields
    class Attribute < SDP::Field
      field_value :attribute
      field_value :value, true
      allow_multiple
      prefix :a

      TOOL_NAME = "RubySDP v#{SDP::VERSION}"

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

      def seed!
        @attribute = 'tool'
        @value = TOOL_NAME
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<attrib>[^:\r\n]+)(:(?<value>[^\r\n]+))?/)
        @attribute = match[:attrib]
        @attribute.force_encoding("US-ASCII")

        if match[:value]
          @value = match[:value]
        end
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
