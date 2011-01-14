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

        session.protocol_version = sdp_hash[0][:protocol_version]
        session.username = sdp_hash[0][:username]
        session.id = sdp_hash[0][:session_id]
        session.version = sdp_hash[0][:session_version]
        session.network_type = sdp_hash[0][:network_type]
        session.address_type = sdp_hash[0][:address_type]
        session.unicast_address = sdp_hash[0][:unicast_address]
        session.name = sdp_hash[0][:session_name]
        session.information = sdp_hash[0][:session_information]
        session.uri = sdp_hash[0][:uri]
        session.email_address = sdp_hash[0][:email_address]
        session.phone_number = sdp_hash[0][:phone_number]
        session.bandwidth_type = sdp_hash[0][:bandwidth_type]
        session.bandwidth = sdp_hash[0][:bandwidth]
        session.connection_address = sdp_hash[0][:connection_address]
        session.start_time = sdp_hash[0][:start_time]
        session.stop_time = sdp_hash[0][:stop_time]
        session.repeat_interval = sdp_hash[0][:repeat_interval]
        session.active_duration = sdp_hash[0][:active_duration]
        session.offsets_from_start_time = sdp_hash[0][:offsets_from_start_time]
        session.time_zone_adjustment = sdp_hash[0][:time_zones][:time_zone_adjustment]
        session.time_zone_offset = sdp_hash[0][:time_zones][:time_zone_offset]
        sdp_hash[0][:attributes].each do |attribute_pair|
          session.attributes = attribute_pair
        end

        session
      end
    end
  end
end