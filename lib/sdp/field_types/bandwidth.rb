require_relative '../field'


class SDP
  module FieldTypes
    class Bandwidth < SDP::Field
      field_value :bandwidth_type
      field_value :bandwidth
      prefix :b

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@bandwidth_type}:#{@bandwidth}\r\n"
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<type>\S+):(?<bandwidth>\S+)/)
        @bandwidth_type = match[:type]
        @bandwidth = match[:bandwidth]
      end
    end
  end
end
