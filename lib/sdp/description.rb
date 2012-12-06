require_relative 'field'
require_relative 'field_group'
require_relative 'runtime_error'

Dir["#{File.dirname(__FILE__)}/field_types/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/field_group_types/*.rb"].each { |f| require f }

class SDP

  # Represents an SDP description as defined in
  # {RFC 4566}[http://tools.ietf.org/html/rfc4566].  This class allows
  # for creating an object so you can, in turn, create a String that
  # represents an SDP description.  The String, then can be used by
  # other protocols that depend on an SDP description.
  #
  # +SDP::Description+ objects are initialized empty (i.e. no fields are
  # defined), putting the onus on you to add fields in the proper order.
  # After building the description up, call +#to_s+ to render it.  This
  # will render the String with fields in order that they were added
  # to the object, so be sure to add them according to spec!
  class Description < FieldGroup

    allowed_field_types
    required_field_types
    allowed_group_types :session_description,
      :time_description,
      :media_description

    required_group_types :session_description


    # @param [Hash] session_as_hash Pass this in to use these values instead
    #   of building your own from scratch.
    def initialize(session_as_hash=nil)
      super()

      add_group(SDP::FieldGroupTypes::SessionDescription.new)
    end

=begin
    # Checks to see if the fields set in the current object will yield an SDP
    # description that meets the RFC 4566 spec.
    #
    # @return [Boolean] true if the object will meet spec; false if not.
    def valid?
      errors.empty?
    end

    # Checks to see if any required fields are not set.
    #
    # @return [Array] The list of unset fields that need to be set.
    def errors

      errors = []
      required_fields.each do |attrib|
        errors << attrib unless self.send(attrib)
      end

      self.each do |section_type, section_values|
        section_values.each do |k, v|
          p k
          p v
          p '--'
          if v.nil? || v.to_s.empty?
            errors << k
          end
        end
      end

      unless has_session_connection_fields? || has_media_connection_fields?
        connection_errors = []

        connection_fields.each do |attrib|
          connection_errors << attrib unless self.send(attrib)
        end

        if connection_errors.empty?
          media_sections.each_with_index do |ms, i|
            connection_fields.each do |attrib|
              unless ms.has_key?(attrib.to_sym)
                connection_errors << "media_section[#{i}][#{attrib}]"
              end
            end
          end
        end

        errors += connection_errors
      end

      errors

      errors = []
      errors += session_description.errors

      unless media_descriptions.empty?
        media_descriptions.each do |media_description|
          errors += media_description
        end
      end

      errors
    end
=end
  end
end
