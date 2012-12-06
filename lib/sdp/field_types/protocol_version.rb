require_relative '../field'


class SDP
  module FieldTypes
    class ProtocolVersion < SDP::Field
      field_value :protocol_version
      prefix :v

      def initialize(init_data=nil)
        @protocol_version = 0
        super(init_data) if init_data
      end

      def to_s
        super

        "#{prefix}=#{@protocol_version}\r\n"
      end

      def seed
        @protocol_version = 0

        self
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<version>\S+)/)
        @protocol_version = match[:version].to_i
      end
    end
  end
end
