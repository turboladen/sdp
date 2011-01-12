require 'sdp/description'
require 'citrus'

class SDP
  module Parser
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      Citrus.load 'lib/sdp/description_grammar.rb'

      SESSION_DESCRIPTION = {
        :protocol_version => /^v=(\S+)/,
        :username => /^o=(\S+)/,
        :id => /^o=\S+\s(\S*)/,
        :version => /^o=\S+\s\S+\s(\S*)/,
        :network_type => /^o=\S+\s\S+\s\S+\s(\S*)/,
        :address_type => /^o=\S+\s\S+\s\S+\s\S+\s(\S*)/,
        :unicast_address => /^o=\S+\s\S+\s\S+\s\S+\s\S+\s(\S*)/,
        :name => /^s=(.*)/,
        :information => /^i=(.*)/,
        :uri => /^u=(\S*)/,
        :email_address => /^e=(.*)/,
        :phone_number => /^p=(.*)/,
        :connection_address => /^c=\S+\s\S+\s(\S+)/,
        :bandwidth_type => /^b=(\w*)/,
        :bandwidth => /^b=\w*\:(\S*)/,
        :start_time => /^t=(\S*)/,
        :stop_time => /^t=\S*\s(\S*)/,
        :repeat_interval => /^r=(\S*)/,
        :active_duration => /^r=\S*\s(\S*)/,
        :offsets_from_start_time => /^r=\S*\s\S*\s(.*)/,
        :time_zone_adjustment => /^z=(\S*)/,
        :time_zone_offset => /^z=\S*\s(\S*)/,
        :encryption_method => /^k=(\w*)/,
        :encryption_key => /^k=\w*\:(\S*)/,
        :attributes => /^a=(\w+):?(.*)?/
      }

      def parse sdp_text
				s = SDPDescription.parse sdp_text
        session_section = s.matches[0]
        media_section = s.matches[1]

        session = SDP::Description.new

        session = parse_session_section_text(session, session_section.to_s)
        #session = parse_media_section_text(session, media_section)

        # Do all session attributes
=begin
        new_attributes = []
        attributes_array.inject({}) do |result, element|
          if element.size = 1
            result = { :attribute => element.first }
          else
            result = { :attribute => element.first, :value => element.last }
          end
          new_attributes << result
          result
        end
        new_attributes.each { |a| session.attributes = a }
=end

        session
      end

      # Do all standard session description fields
      def parse_session_section_text(session, session_section_text)
        SESSION_DESCRIPTION.each_pair do |sdp_type, regex|
          session_section_text =~ regex

          value = $1.strip unless $1.nil?

          if sdp_type == :attributes
            attribute = value
            attribute_value = $2.strip unless $2.nil?
            value = {}
            value[:attribute] = attribute
            value[:value] = attribute_value
          end
          session.send("#{sdp_type}=", value)
        end

        session
      end

      def parse_media_section_text(session, media_section_text)
      end
    end
  end
end