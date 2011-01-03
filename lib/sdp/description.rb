require 'etc'
require 'sdp/description_field'

class SDP
  class Description < Hash

    # TODO: The origin <username> MUST NOT contain spaces.
    # TODO: Its
    #      usage is up to the creating tool, so long as <sess-version> is
    #      increased when a modification is made to the session data.  Again,
    #      it is RECOMMENDED that an NTP format timestamp is used.
    def initialize fields={}
      register_field :version
      register_field :origin
      register_field :session_name
      register_field :session_information
      register_field :uri
      register_field :email_address
      register_field :phone_number
      register_field :connection_data
      register_field :bandwidth
      register_field :timing
      register_field :media_description
    end

    def register_field(field_type)
      retried = false

      begin
        const_name = field_type.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
        field = SDP::DescriptionFields.const_get("#{const_name}Field").new
        store(field.ruby_type, field)
      rescue NameError
        if retried then
          raise
        else
          retried = true
          require "sdp/description_fields/#{field_type.to_s}"
          retry
        end
      end
    end

    def []=(field_type, field_value)
      retried = false

      begin
        const_name = field_type.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
        field = SDP::DescriptionFields.const_get("#{const_name}Field").new(field_value)
        store(field.ruby_type, field)
      rescue NameError
        if retried then
          raise
        else
          retried = true
          require "sdp/description_fields/#{field_type.to_s}"
          retry
        end
      end
    end

    def to_s
      sdp_string = self[:version].to_sdp_s
      sdp_string << add_to_string(:origin)
      sdp_string << add_to_string(:session_name)
      sdp_string << add_to_string(:session_information)
      sdp_string << add_to_string(:uri)
      sdp_string << add_to_string(:email_address)
      sdp_string << add_to_string(:phone_number)
      sdp_string << add_to_string(:connection_data)
      sdp_string << add_to_string(:bandwidth)
      sdp_string << add_to_string(:timing)
      sdp_string << add_to_string(:media_description)
    end

    def add_to_string field_type
      self[field_type].valid? ? self[field_type].to_sdp_s : ""
    end
  end
end
