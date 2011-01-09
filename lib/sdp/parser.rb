require 'sdp/description'

class SDP
  module Parser
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      SDP_TYPE = {
        :version => /^v=(.*)/,
        :origin => /^o=(.*)/,
        :session_name => /^s=(.*)/,
        :session_information => /^i=(.*)/,
        :uri => /^u=(.*)/,
        :email_address => /^e=(.*)/,
        :phone_number => /^p=(.*)/,
        :connection_data => /^c=(.*)/,
        :bandwidth => /^b=(.*)/,          # Multi-type
        :timing => /^t=(.*)/,             # Multi-type
        :repeat_times => /^r=(.*)/,       # Multi-type
        :time_zones => /^z=(.*)/,         # Multi-type
        :encryption_keys => /^k=(.*)/,    # Multi-type
        :attribute => /^a=(.*)/
      }

      def parse sdp_text
        sdp = SDP::Description.new

        SDP_TYPE.each_pair do |sdp_type, regex|
          sdp_text =~ regex

=begin
          if sdp_type == :origin
            sdp[sdp_type] = parse_origin $1
          elsif sdp_type == :connection_data
            sdp[sdp_type] = parse_connection_data $1
          else
            sdp[sdp_type] = $1
          end
=end
          value = $1.strip unless $1.nil?
          sdp.add_field(sdp_type, value)
        end

        sdp
      end

      def parse_origin origin_line
        origin = {}
        origin_params = origin_line.split(" ")
        origin[:username]         = origin_params[0]
        origin[:session_id]       = origin_params[1]
        origin[:session_version]  = origin_params[2].to_i # Should be NTP timestamp
        origin[:net_type]         = origin_params[3]
        origin[:address_type]     = origin_params[4].to_sym
        origin[:unicast_address]  = origin_params[5]

        origin
      end

      # c= can show up multiple times...
      # If :connection_address has a trailing /127 (ex), 127 = ttl; only IP4 though.
      def parse_connection_data connection_data_line
        connection_data = {}
        connection_data_params = connection_data_line.split(" ")
        connection_data[:net_type]            = connection_data_params[0]
        connection_data[:address_type]        = connection_data_params[1].to_sym
        connection_data[:connection_address]  = connection_data_params[2]

        connection_data
      end
    end
  end
end