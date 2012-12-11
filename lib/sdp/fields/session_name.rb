require_relative '../field'


class SDP
  module Fields
    class SessionName < SDP::Field
      field_value :name
      prefix :s

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@name}\r\n"
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<name>[^\r\n]+)/)
        @name = match[:name]
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
