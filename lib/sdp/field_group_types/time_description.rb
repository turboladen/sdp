require_relative '../field_group'


class SDP
  module FieldGroupTypes
    class TimeDescription < SDP::FieldGroup
      allowed_field_types :timing, :repeat_times
      allowed_group_types

      required_field_types :timing
      required_group_types

      line_order :timing, :repeat_times

      allow_multiple

      def seed
        add_field(:timing) unless has_field?(:timing)

        super
      end
    end
  end
end
