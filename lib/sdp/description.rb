# encoding: utf-8
require 'erb'
require File.expand_path(File.dirname(__FILE__) + '/runtime_error')
require_relative 'session_description'
require_relative 'media_description'

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
  class Description < Hash

    # @param [Hash] session_as_hash Pass this in to use these values instead
    #   of building your own from scratch.
    def initialize(session_as_hash=nil)
      super()

      if session_as_hash.nil?
        self[:session_description] = SessionDescription.new
        self[:media_descriptions] = []
      else
        self[:session_description] =
          SessionDescription.new(session_as_hash[:session_description])

        self[:media_descriptions] = session_as_hash[:media_descriptions].map do |md|
          MediaDescription.new(md[:media_description])
        end
      end
    end

    # @param [SDP::SessionDescription] sd The new SDP::SessionDescription.
    # @raise [SDP::RuntimeError] If +sd+ is not an SDP::SessionDescription.
    def session_description=(sd)
      raise SDP::RuntimeError unless sd.is_a? SDP::SessionDescription

      self[:session_description] = sd
    end

    # @return [SDP::SessionDescription]
    def session_description
      self[:session_description]
    end

    # @return [Array<SDP::MediaDescription>]
    def media_descriptions
      self[:media_descriptions]
    end

    # Seeds the SessionDescription with some basic data.
    #
    # @see SDP::SessionDescription#seed
    def seed
      session_description.seed

      self
    end

    # Turns the current +SDP::Description+ object into the SDP description,
    # ready to be used.
    #
    # @return [String] The SDP description.
    def to_s
      session = session_description.to_s

      unless media_descriptions.empty?
        media_descriptions.each do |media_section|
          session << media_section.to_s
        end
      end

      session
    end

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
=begin
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
=end
      errors = []
      errors += session_description.errors

      unless media_descriptions.empty?
        media_descriptions.each do |media_description|
          errors += media_description
        end
      end

      errors
    end
  end
end
