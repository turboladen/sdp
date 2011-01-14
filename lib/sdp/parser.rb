require 'sdp/description'
require 'sdp/description_parser'

class SDP
  module Parser
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def parse sdp_text
        session = SDP::Description.new
				sdp_hash = SDPDescription.new.parse sdp_text
        session_section = sdp_hash[:session_section]

        session.protocol_version = session_section[:protocol_version]
        session.username = session_section[:username]
        session.id = session_section[:session_id]
        session.version = session_section[:session_version]
        session.network_type = session_section[:network_type]
        session.address_type = session_section[:address_type]
        session.unicast_address = session_section[:unicast_address]
        session.name = session_section[:session_name]
        session.information = session_section[:session_information]
        session.uri = session_section[:uri]
        session.email_address = session_section[:email_address]
        session.phone_number = session_section[:phone_number]
        session.bandwidth_type = session_section[:bandwidth_type]
        session.bandwidth = session_section[:bandwidth]
        session.connection_address = session_section[:connection_address]
        session.start_time = session_section[:start_time]
        session.stop_time = session_section[:stop_time]
        session.repeat_interval = session_section[:repeat_interval]
        session.active_duration = session_section[:active_duration]
        session.offsets_from_start_time = session_section[:offsets_from_start_time]

        if session_section[:time_zones]
          session.time_zone_adjustment = session_section[:time_zones][:time_zone_adjustment]
          session.time_zone_offset = session_section[:time_zones][:time_zone_offset]
        end

        session_section[:attributes].each do |attribute_pair|
          session.attributes = attribute_pair
        end

        sdp_hash.shift
        sdp_hash.each do |media_description|
          session.media_descriptions == media_description
        end

        session
      end
    end
  end
end