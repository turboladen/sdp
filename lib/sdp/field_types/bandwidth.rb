require_relative '../field_type'
require_relative '../field_type_group'


class SDP
  module FieldTypes
    class BandwidthLine < SDP::FieldType
      attr_accessor :bandwidth_type
      attr_accessor :bandwidth

      def initialize(init_data=nil)
        @bandwidth_type = nil
        @bandwidth = nil

        @prefix = "b"

        super(init_data) if init_data
      end

      def to_s
        super

        "#{@prefix}=#{@bandwidth_type}:#{@bandwidth}"
      end

      private

      def add_from_string(init_data)
        /b=(?<t>\S+):(?<b>\S+)/ =~ init_data
        @bandwidth_type = t
        @bandwidth = b
      end
    end

    class Bandwidth < SDP::FieldTypeGroup
    end
  end
end
