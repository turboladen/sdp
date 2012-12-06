require_relative '../field_group'
require_relative 'time_description'

Dir["#{File.dirname(__FILE__)}/field_types/*.rb"].each { |f| require f }


class SDP
  module FieldGroupTypes
    class SessionDescription < SDP::FieldGroup

      # The FieldTypes that can belong in a session description.
      allowed_field_types :protocol_version,
        :origin,
        :session_name,
        :session_information,
        :uri,
        :email_address,
        :phone_number,
        :connection_data,
        :bandwidth,
        :time_zone_adjustments,
        :encryption_key,
        :attribute

      # The FieldTypes that *must* belong in a session description.
      required_field_types :protocol_version,
        :origin,
        :session_name

      allowed_group_types :time_description
      required_group_types :time_description

      def initialize
        super()

        add_field(SDP::FieldTypes::ProtocolVersion.new)
        add_field(SDP::FieldTypes::Origin.new)
        add_field(SDP::FieldTypes::SessionName.new)
        add_group(SDP::FieldGroupTypes::TimeDescription.new)
      end
    end
  end
end
