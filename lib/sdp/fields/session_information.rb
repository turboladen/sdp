require_relative '../field'


class SDP
  module Fields
    class SessionInformation < SDP::Field
      field_value :session_description
      prefix :i

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@session_description}\r\n"
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<description>[^\r\n]+)/)
        @session_description = match[:description]
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
