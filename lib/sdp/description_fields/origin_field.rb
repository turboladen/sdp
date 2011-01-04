require 'etc'
require 'sdp/description_field'

class SDP::DescriptionFields
  class OriginField < SDP::DescriptionField

    # TODO: The origin <username> MUST NOT contain spaces.
    # TODO: Its
    #      usage is up to the creating tool, so long as <sess-version> is
    #      increased when a modification is made to the session data.  Again,
    #      it is RECOMMENDED that an NTP format timestamp is used.
    def initialize value=nil
      @sdp_type = 'o'
      @ruby_type = :origin
      @required = true

      @value = {
        :username => Etc.getlogin,
        :session_id => Time.now.to_i,
        :session_version => Time.now.to_i,
        :net_type => :IN,
        :address_type => :IP4,
        :unicast_address => get_local_ip
      }

      unless value.nil?
        super
        map_values
      end
    end

    # If a values string was passed in, the parent class broken those up
    # to an Array.  This maps those values to the value Hash.
    def map_values
      @value[:username]         = @parsed_values[0]
      @value[:session_id]       = @parsed_values[1]
      @value[:session_version]  = @parsed_values[2]
      @value[:net_type]         = @parsed_values[3]
      @value[:address_type]     = @parsed_values[4]
      @value[:unicast_address]  = @parsed_values[5]
    end
  end
end
