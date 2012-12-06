require_relative '../field_group'


class SDP
  module FieldGroupTypes
    class TimeDescription < SDP::FieldGroup

      # The FieldTypes that can belong in a session description.
      allowed_field_types :timing, :repeat_times

      # The FieldTypes that *must* belong in a session description.
      required_field_types :timing

      allowed_group_types
      required_group_types

      def initialize
        super()

        add_field(SDP::FieldTypes::Timing.new)
      end
    end
  end
end
