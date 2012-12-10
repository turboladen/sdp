require_relative '../group'
require_relative 'time_description'

Dir["#{File.dirname(__FILE__)}/fields/*.rb"].each { |f| require f }


class SDP
  module Groups

    # This represents the session section of a session description.
    class SessionSection < SDP::Group

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

      required_field_types :protocol_version,
        :origin,
        :session_name

      allowed_group_types :time_description
      required_group_types :time_description
      line_order :protocol_version,
        :origin,
        :session_name,
        :session_information,
        :uri,
        :email_address,
        :phone_number,
        :connection_data,
        :bandwidth,
        :time_description,
        :time_zone_adjustments,
        :encryption_key,
        :attribute

      def seed
        [:protocol_version, :origin, :session_name].each do |field|
          add_field(field) unless has_field?(field)
        end

        add_group(:time_description) unless has_group?(:time_description)

        super
      end
    end
  end
end
