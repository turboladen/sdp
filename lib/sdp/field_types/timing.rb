require_relative '../field_type'
require_relative '../field_type_group'


class SDP
  module FieldTypes
    class TimingLine < SDP::FieldType
      attr_accessor :start_time
      attr_accessor :stop_time

      def initialize(init_data=nil)
        @start_time = nil
        @stop_time = nil

        @prefix = "t"

        super(init_data) if init_data
      end

      def to_s
        super

        "#{@prefix}=#{@start_time} #{@stop_time}\r\n"
      end

      def seed
        @start_time = 0
        @stop_time = 0
      end

      private

      def add_from_string(init_data)
        /t=(?<start>\S+) (?<stop>\S+)/ =~ init_data
        @start_time = start
        @stop_time = stop
      end
    end

    class Timing < SDP::FieldTypeGroup
      def seed
        add_line(start_time: 0, stop_time: 0)
      end
    end
  end
end
