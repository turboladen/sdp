require_relative '../field'


class SDP
  module FieldTypes
    class RepeatTimes < SDP::Field
      field_value :repeat_interval
      field_value :active_duration
      field_value :offsets_from_start_time
      prefix :r

      def initialize(init_data=nil)
        @offsets_from_start_time = []
        super(init_data) if init_data
      end

      def to_s
        super

        s = "#{prefix}=#{@repeat_interval} #{@active_duration}"
        s << @offsets_from_start_time.join(" ")
        s << "\r\n"

        s
      end

      private

      def add_from_string(init_data)
        m = init_data.match(/#{prefix}=(?<interval>\S+) (?<duration>\S+) (?<offsets>[^\r\n]+)/)
        @repeat_interval = Integer(m[:interval]) rescue m[:interval]
        @active_duration = Integer(m[:duration]) rescue m[:duration]
        @offsets_from_start_time = m[:offsets].split(' ')
      end
    end
  end
end
