require_relative '../field'
require_relative '../version'


class SDP
  module Fields
    class Attribute < SDP::Field
      field_value :type
      field_value :value, true
      allow_multiple
      prefix :a

      TOOL_NAME = "RubySDP v#{SDP::VERSION}"

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        s = "#{prefix}=#{@type}"
        s << ":#{@value}" if @value
        s << "\r\n"

        s
      end

      def seed!
        @type = 'tool'
        @value = TOOL_NAME
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<type>[^:\r\n]+)(:(?<value>[^\r\n]+))?/)
        @type = match[:type]
        @type.force_encoding("US-ASCII")

        if match[:value]
          @value = match[:value]
        end
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
