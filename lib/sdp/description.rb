require 'logger'

class SDP

  # Represents an SDP description as defined in RFC 4566.  This class allows
  # for creating an object so you can, in turn, create a String that
  # represents an SDP description.  The String, then can be used by
  # other protocols that depend on an SDP description.
  # 
  # SDP::Description objects are initialized empty (i.e. no fields are
  # defined), putting the onus on you to add fields in the proper order.
  # After building the description up, call #to_s to render it.  This
  # will render the String with fields in order that they were added
  # to the object, so be sure to add them according to spec!
  class Description < Hash
    def initialize
      self[:session_description] = {}
      self[:media_descriptions] = []
      protocol_version = 0
    end

    # Set the Session description section's version field value.
    def protocol_version=(version)
      self[:session_description][:version] = create_field_object :version
      self[:session_description][:version].value = version

      self[:session_description][:version].value
      add_field(:session_description, :version, version)
    end

    # @return [Fixnum]
    def protocol_version
      self[:session_description][:version].value
    end

    def username=(new_username)
      add_field(:session_description, :origin, new_username, :username)
    end

    def username
      self[:session_description][:origin].value[:username]
    end

    def id=(new_session_id)
      add_field(:session_description, :origin, new_session_id, :session_id)
    end

    def id
      self[:session_description][:origin].value[:session_id]
    end

    def version=(new_session_version)
      add_field(:session_description, :origin, new_session_version, :session_version)
    end

    def version
      self[:session_description][:origin].value[:session_version]
    end

    def network_type=(new_network_type)
      add_field(:session_description, :origin, new_network_type, :net_type)
      add_field(:session_description, :connection_data, new_network_type, :net_type)
    end

    def network_type
      self[:session_description][:origin].value[:net_type] ||
      self[:seesion_description][:connection_data].value[:net_type]
    end

    def address_type=(new_address_type)
      add_field(:session_description, :origin, new_address_type, :address_type)
    end

    def address_type
      self[:session_description][:origin].value[:address_type]
    end

    def unicast_address=(new_unicast_address)
      add_field(:session_description, :origin, new_unicast_address, :unicast_address)
    end

    def unicast_address
      self[:session_description][:origin].value[:unicast_address]
    end

    def name=(new_session_name)
      add_field(:session_description, :session_name, new_session_name)
    end

    def name
      self[:session_description][:session_name].value
    end

    def information=(new_session_information)
      add_field(:session_description, :session_information, new_session_information)
    end

    def information
      self[:session_description][:session_information].value
    end

    def uri=(new_uri)
      add_field(:session_description, :uri, new_uri)
    end

    def uri
      self[:session_description][:uri].value
    end

    def email_address=(new_email_address)
      add_field(:session_description, :email_address, new_email_address)
    end

    def email_address
      self[:session_description][:email_address].value
    end

    def connection_address=(new_connection_address)
      add_field(:session_description, :connection_data,
        new_connection_address, :connection_address)
    end

    def connection_address
      self[:session_description][:connection_data].value[:connection_address]
    end

    def start_time=(new_start_time)
      add_field(:session_description, :timing, new_start_time, :start_time)
    end

    def start_time
      self[:session_description][:timing].value[:start_time]
    end

    def stop_time=(new_stop_time)
      add_field(:session_description, :timing, new_stop_time, :stop_time)
    end

    def stop_time
      self[:session_description][:timing].value[:stop_time]
    end

    # Add a new Media description section.
    def media=(new_media_description)
      media_description_field = create_field_object :media_description
      media_description_field.value = new_media_description
      self[:media_descriptions] << media_description_field

      self[:media_descriptions].last.value
    end

    # @return [Array]
    def media
      self[:media_descriptions].collect { |m| m.value }
    end

    # Turns the current SDP::Description object into the SDP description,
    # ready to be used.
    #
    # @return [String] The SDP description.
    def to_s
=begin
      sdp_string = add_to_string(:version)
      sdp_string << add_to_string(:origin)
      sdp_string << add_to_string(:session_name)
      sdp_string << add_to_string(:session_information)
      sdp_string << add_to_string(:uri)
      sdp_string << add_to_string(:email_address)
      sdp_string << add_to_string(:phone_number)
      sdp_string << add_to_string(:connection_data)
      sdp_string << add_to_string(:bandwidth)
      sdp_string << add_to_string(:timing)
      sdp_string << add_to_string(:repeat_times)
      sdp_string << add_to_string(:time_zones)
      sdp_string << add_to_string(:encryption_keys)
      sdp_string << add_to_string(:attribute)
      sdp_string << add_to_string(:media_description)
=end
      sdp_string = self[:session_description][:version].to_sdp_s
      sdp_string << self[:session_description][:origin].to_sdp_s
      sdp_string << self[:session_description][:session_name].to_sdp_s
      sdp_string << self[:session_description][:session_information].to_sdp_s
      sdp_string << self[:session_description][:uri].to_sdp_s
      sdp_string << self[:session_description][:email_address].to_sdp_s
      sdp_string << self[:session_description][:connection_data].to_sdp_s
      sdp_string << self[:session_description][:timing].to_sdp_s
      self[:media_descriptions].each do |m|
        sdp_string << m.to_sdp_s
      end

      sdp_string
    end

    #----------------------------------------------------------------------
    # PRIVATES!
    private

    # Takes a Symbol that represents an SDP field type, then creates the
    # corresponding [type]Field object and returns it.  Field classes are
    # defined in the ./description_fields/ directory.
    #
    # @param [Symbol] field_type
    # @return [] Returns the SDP::DescriptionField child class described
    # by the value passed in.
    def create_field_object(field_type)
      retried = false

      begin
        const_name = field_type.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
        field = SDP::DescriptionFields.const_get("#{const_name}Field").new
      rescue NameError
        if retried then
          raise
        else
          retried = true
          require File.dirname(__FILE__) + "/description_fields/#{field_type.to_s}_field"
          retry
        end
      end

      field
    end

    def add_field(description_hash, field_type, value, value_key=nil)
      unless self[description_hash].has_key? field_type
        self[description_hash][field_type] = create_field_object field_type
      end

      if value_key.nil?
        self[description_hash][field_type].value = value
      else
        self[description_hash][field_type].value[value_key] = value
      end

      self[description_hash][field_type].value
      
    end

    # Converts a DescriptionField child to a String that is used in an SDP
    # description.
    # 
    # @param [Symbol] field_type
    # @return [String] The line used in an SDP description.
    def add_to_string field_type
      field = find_field(field_type)

      string = if field.first.nil?
        @logger.debug "field is nill"
        ""
      elsif field.first.valid?
        field.first.to_sdp_s
      else
        ""
      end
    end

    # Finds a field by type and value.  Needed in order to properly add
    # to the output string as well as assign new values to the field.
    # 
    # @param [Symbol] field_type
    # @param [] field_value
    # @return [Array] The object and its position in self's Array.
    def find_fields(field_type, field_value=nil)
      @logger.debug "field type: #{field_type}"

      fields = self.find_all do |f|
        @logger.debug "f: #{f}"
        @logger.debug "f.ruby_type: #{f.ruby_type}"
        f.ruby_type == field_type
      end

      @logger.debug "fields: #{fields}"

      if fields.length == 1
        return [fields.first, self.index(fields.first)]
      else
        all_fields = []

        fields.each do |field|
          all_fields << [field, self.index(field)]
        end

        return all_fields
      end
    end
  end
end
