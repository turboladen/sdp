require_relative 'runtime_error'

class SDP
  class MediaDescription
    ALLOWED_TYPES = [
      :video, :audio, :text, :application, :message, :control, :data
    ]

    def initialize(type)
      @type = type
    end

    def media=(type)
      unless ALLOWED_TYPES.include? type
        raise SDP::RuntimeError,
          "Media type '#{type}' must be in list #{ALLOWED_TYPES.join(', ')}"
      end

      @media = type
    end

    # The transport port to which the media stream is sent.
    def transport_port=(port)
      if port.match /\//

      end
    end

    def transport_protocol=(protocol)

    end

    def to_s
      session = "m=#{m[:media]} #{m[:port]} #{m[:protocol]} #{m[:format]}\r\n"

      if m[:attributes]
        m[:attributes].each do |a|
          session << "a=#{a[:attribute]}"
          session << ":#{a[:value]}" if a[:value]
          session << "\r\n"
        end
      end

      session
    end

    # Checks to see if it has connection fields set.
    #
    # @return [Boolean]
    def has_connection_fields?
      !!(connection_network_type && connection_address_type &&
        connection_address)
    end
  end
end
