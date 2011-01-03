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
      self[:version]            = SDP_VERSION
      self[:origin]             = Etc.getlogin
      self[:session_name]       = " "
      self[:timing]             = "0 0"
      self[:media_description]  = ""
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
      sdp_string << self[:origin].to_sdp_s
      sdp_string << self[:session_name].to_sdp_s
      sdp_string << self[:timing].to_sdp_s
      sdp_string << self[:media_description].to_sdp_s
    end
  end
end
