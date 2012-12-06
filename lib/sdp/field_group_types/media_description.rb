require_relative '../field_group'

Dir["#{File.dirname(__FILE__)}/field_types/*.rb"].each { |f| require f }


class SDP
  module FieldGroupTypes
    class MediaDescription < SDP::FieldGroup

      # The FieldTypes that can belong in a session description.
      allowed_field_types :media_description,
        :session_information,
        :connection_data,
        :bandwidth,
        :encryption_key,
        :attribute

      # The FieldTypes that *must* belong in a session description.
      required_field_types :media_description

      allowed_group_types
      required_group_types

      def initialize
        super()

        add_field(SDP::FieldTypes::MediaDescription.new)
      end
    end
  end
end
