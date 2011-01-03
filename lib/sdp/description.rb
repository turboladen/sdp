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
  class Description < Array
    def initialize
      @logger = Logger.new STDOUT
      @logger.level = Logger::WARN
    end

    # Adds a new field to the SDP object based on the field type and field
    # value (if given).
    # 
    # @param [Symbol] field_type
    # @param [] field_value
    def add_field(field_type, field_value=nil)
      field = create_field_object(field_type)

      @logger.debug "field: #{field}"
      @logger.debug "field.ruby_type: #{field.ruby_type}"

      self << field

      @logger.debug self
      @logger.debug "field_value: #{field_value}"
      @logger.debug "self.last: #{self.last}"

      if field_value
        self.last.value = field_value
      end
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
      sdp_string = ""
      self.each do |field|
        sdp_string << field.to_sdp_s
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
          require "sdp/description_fields/#{field_type.to_s}"
          retry
        end
      end

      field
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
    def find_field(field_type, field_value=nil)
      @logger.debug "field type: #{field_type}"

      field = self.find do |f|
        @logger.debug "f: #{f}"
        @logger.debug "f.ruby_type: #{f.ruby_type}"
        f.ruby_type == field_type
      end

      @logger.debug "field: #{field}"
      return [field, self.index(field)]
    end
  end
end
