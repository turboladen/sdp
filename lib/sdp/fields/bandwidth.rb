require_relative '../field'


class SDP
  module Fields
    class Bandwidth < SDP::Field
      field_value :modifier
      field_value :value
      prefix :b
      allow_multiple

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@modifier}:#{@value}\r\n"
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<type>\S+):(?<value>\S+)/)
        @modifier = match[:type]
        @value = match[:value]
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
