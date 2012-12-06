require_relative '../field'


class SDP
  module FieldTypes
    class Media < SDP::Field
      field_value :media
      field_value :port
      field_value :transport_protocol
      field_value :format
      prefix :m

      # Types of media that RFC 4566 says are currently supported.
      MEDIA_TYPES = %w[audio video text application message control data]

      # Protocol types that RFC 4566 says are currently supported.
      PROTOCOL_TYPES = %w[udp RTP/AVP RTP/SAVP]

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        check_media_type
        check_protocol_type

        "#{prefix}=#{@media} #{@port} #{@transport_protocol} #{@format}\r\n"
      end

      private

      def add_from_string(init_data)
        m = init_data.match(/#{prefix}=(?<m>\S+) (?<p>\d+) (?<t>\S+) (?<f>[^\r\n]+))?/)
        @media = m[:m]
        @port = m[:p]
        @transport_protocol = m[:t]
        @format = m[:f]

        check_media_type
        check_protocol_type
      end

      def check_protocol_type
        unless PROTOCOL_TYPES.include? @transport_protocol.to_s
          warn "Transport protocol '#{@transport_protocol}' is not " +
            "in the known list: #{PROTOCOL_TYPES}"
        end
      end

      def check_media_type
        unless MEDIA_TYPES.include? @media.to_s
          warn "Media type '#{@media}' is not in the known list: #{MEDIA_TYPES}"
        end
      end
    end
  end
end
