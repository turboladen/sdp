require_relative '../field'


class SDP
  module FieldTypes
    class PhoneNumber < SDP::Field
      field_value :phone_number
      prefix :p

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@phone_number}\r\n"
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<number>[^\r\n]+)/)
        @phone_number = match[:number]
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
