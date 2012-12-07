require_relative '../field'


class SDP
  module FieldTypes
    class TimeZoneAdjustments < SDP::Field
      field_value :adjustment_sets
      prefix :z

      def initialize(init_data=nil)
        @adjustment_sets = []
      end

      def to_s
        super

        "#{prefix}=#{@session_name}\r\n"
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<adjustments>[^\r\n]+)/)
        values = match[:adjustments].split(' ')

        until values.empty?
          key, value = values.shift(2)
          @adjustment_sets << { key => value }
        end
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end
    end
  end
end
