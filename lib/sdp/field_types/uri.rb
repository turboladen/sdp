require_relative '../field'


class SDP
  module FieldTypes
    class URI < SDP::Field
      field_value :uri
      prefix :u

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@uri}\r\n"
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<uri>\S+)/)
        @uri = match[:uri]
      end
    end
  end
end
