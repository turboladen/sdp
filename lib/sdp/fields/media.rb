require_relative '../field'


class SDP
  module Fields
    class Media < SDP::Field
      field_value :type
      field_value :port
      field_value :protocol
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

        "#{prefix}=#{@type} #{@port} #{@protocol} #{@format}\r\n"
      end

      private

      def add_from_string(init_data)
        m = init_data.match(/#{prefix}=(?<m>\S+) (?<p>\S+) (?<t>\S+) (?<f>[^\r\n]+)?/)
        @type = m[:m]
        @port = m[:p]
        @protocol = m[:t]
        @format = m[:f]

        check_media_type
        check_protocol_type
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end

      def check_protocol_type
        unless PROTOCOL_TYPES.include? @protocol.to_s
          warn "Transport protocol '#{@protocol}' is not " +
            "in the known list: #{PROTOCOL_TYPES}"
        end
      end

      def check_media_type
        unless MEDIA_TYPES.include? @type.to_s
          warn "Media type '#{@type}' is not in the known list: #{MEDIA_TYPES}"
        end
      end
    end
  end
end
