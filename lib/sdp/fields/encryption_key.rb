require_relative '../field'


class SDP
  module Fields
    class EncryptionKey < SDP::Field
      field_value :encryption_method
      field_value :encryption_key, true
      prefix :k

      # Encryption methods that RFC 4566 says are supported.
      DEFINED_METHODS = %w[clear base64 uri prompt]

      def initialize(init_data=nil)
        super(init_data) if init_data
      end

      def to_s
        super

        check_method

        s = "#{prefix}=#{@encryption_method}"
        s << ":#{@encryption_key}" if @encryption_key
        s << "\r\n"

        s
      end

      private

      def add_from_string(init_data)
        match = init_data.match(/#{prefix}=(?<m>\w+)( :(?<key>[^\r\n]+))?/)
        @encryption_method = match[:m]
        check_method

        if match[:key]
          @encryption_key = match[:key]
        end
      rescue NoMethodError
        raise SDP::ParseError, "Error parsing string '#{init_data}'"
      end

      def check_method
        unless DEFINED_METHODS.include? @encryption_method
          warn "Encryption field using undefined method: #{@encryption_method}"
        end
      end
    end
  end
end
