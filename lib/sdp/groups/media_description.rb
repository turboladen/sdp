require_relative '../group'


class SDP
  module Groups
    class MediaDescription < SDP::Group

      # The Fields that can belong in a session description.
      allowed_field_types :media,
        :session_information,
        :connection_data,
        :bandwidth,
        :encryption_key,
        :attribute

      # The Fields that *must* belong in a session description.
      required_field_types :media

      allowed_group_types
      required_group_types

      line_order :media,
        :session_information,
        :connection_data,
        :bandwidth,
        :encryption_key,
        :attribute

      allow_multiple

      def seed
        add_field(:media) unless has_field?(:media)

        super
      end
    end
  end
end
