require_relative '../field'


class SDP
  module FieldTypes
    class EmailAddress < SDP::Field
      field_value :email_address
      prefix :e

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@email_address}\r\n"
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<address>[^\r\n]+)/)
        @email_address = match[:address]
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
