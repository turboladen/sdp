require_relative '../field'


class SDP
  module FieldTypes
    class Timing < SDP::Field
      field_value :start_time
      field_value :stop_time
      prefix :t

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@start_time} #{@stop_time}\r\n"
      end

      def seed
        @start_time = 0
        @stop_time = 0

        self
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<start>\S+) (?<stop>\S+)/)
        @start_time = Integer(match[:start]) rescue match[:start]
        @stop_time = Integer(match[:stop]) rescue match[:start]
      end
    end
  end
end
