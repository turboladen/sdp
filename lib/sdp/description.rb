# encoding: utf-8
require 'erb'
require File.expand_path(File.dirname(__FILE__) + '/runtime_error')

class SDP
  PROTOCOL_VERSION = 0

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
    class << self

      # Class macro to access the different fields that make up the
      # description.
      #
      # @param [Symbol] field_type
      def field(field_type)
        define_read_field_method(field_type)
        define_write_field_method(field_type)
      end

      # Creates read accessor for the field type.  This simply reads
      # the correct Hash value and returns that.
      #
      # @param [Symbol] field_type
      # @return [] Returns whatever type the value is that's stored
      #   in the Hash key.
      def define_read_field_method(field_type)
        define_method field_type do
          if field_type == :media_sections
            self[:media_sections]
          else
            self[:session_section][field_type]
          end
        end
      end

      # Creates write accessor for the field type.  This simply writes
      # the correct Hash value and returns that.
      #
      # @param [Symbol] field_type
      def define_write_field_method(field_type)
        case field_type
        when :media_sections
          define_method ":media_sections<<" do |value|
            self[:media_sections] << value
          end
        when :time_zones || :attributes
          define_method "#{field_type}<<" do |value|
            self[:session_section][field_type] << value
          end
        else
          define_method "#{field_type}=" do |value|
            self[:session_section][field_type] = value
          end
        end
      end
    end

    FIELDS = [
      :protocol_version,
      :username,
      :id,
      :version,
      :network_type,
      :address_type,
      :unicast_address,
      :name,
      :information,
      :uri,
      :email_address,
      :phone_number,
      :connection_network_type,
      :connection_address_type,
      :connection_address,
      :bandwidth_type,
      :bandwidth,
      :start_time,
      :stop_time,
      :repeat_interval,
      :active_duration,
      :offsets_from_start_time,
      :time_zones,
      :encryption_method,
      :encryption_key,
      :attributes,
      :media_sections
    ]

    FIELDS.each do |field_type|
      field field_type
    end

    # @param [Hash] session_as_hash Pass this in to use these values instead
    #   of building your own from scratch.
    def initialize(session_as_hash=nil)
      if session_as_hash.nil?
        self[:session_section] = {}
        self[:session_section][:time_zones] = []
        self[:session_section][:attributes] = []
        self[:media_sections] = []

        self.send :protocol_version=, SDP::PROTOCOL_VERSION
      else
        begin
          unless validate_init_value(session_as_hash)
            self.replace session_as_hash
          end
        rescue SDP::RuntimeError => ex
          puts ex.message
          raise
        end
      end

      super
    end

    # Turns the current +SDP::Description+ object into the SDP description,
    # ready to be used.
    #
    # @return [String] The SDP description.
    def to_s
      session_template
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
      errors = []
      required_fields.each do |attrib|
        errors << attrib unless self.send(attrib)
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
    end

    #--------------------------------------------------------------------------
    # PRIVATES!
    private

    # Fields required by the RFC.
    #
    # @return [Array<String>]
    def required_fields
      %w[protocol_version username id version network_type address_type
        unicast_address name start_time stop_time media_sections]
    end

    # Fields that make up the connection line.
    #
    # @return [Array<String>]
    def connection_fields
      %w[connection_network_type connection_address_type connection_address]
    end

    # Checks to see if it has connection fields set in the session section.
    #
    # @return [Boolean]
    def has_session_connection_fields?
      !!(connection_network_type && connection_address_type &&
        connection_address)
    end

    def has_media_connection_fields?
      return false if media_sections.empty?

      media_sections.any? do |ms|
        !!(ms.has_key?(:connection_network_type) &&
          ms.has_key?(:connection_address_type) &&
          ms.has_key?(:connection_address))
      end
    end

    # @return [Binding] Values for this object for ERB to use.
    def get_binding
      binding
    end

    # @raise [SDP::RuntimeError] If not given a Hash.
    def validate_init_value value
      unless value.class == Hash
        message =
          "Must pass a Hash in on initialize.  You passed in a #{value.class}."
        raise SDP::RuntimeError, message
      end

      bad_keys = []
      value.each_key do |key|
        bad_keys << key unless (FIELDS.include?(key) || key == :session_section)
      end

      unless bad_keys.empty?
        message = "Invalid key value passed in on initialize: #{bad_keys}"
        raise SDP::RuntimeError, message
      end
    end

    def session_template
      session = <<-TMP
v=#{protocol_version}\r
o=#{username} #{id} #{version} #{network_type} #{address_type} #{unicast_address}\r
s=#{name}\r
      TMP

      session << "i=#{information}\r\n"                   if information
      session << "u=#{uri}\r\n"                           if uri
      session << "e=#{email_address}\r\n"                 if email_address
      session << "p=#{phone_number}\r\n"                  if phone_number

      if connection_network_type
        session << "c=#{connection_network_type} #{connection_address_type} #{connection_address}\r\n"
      end

      session << "b=#{bandwidth_type}:#{bandwidth}\r\n"   if bandwidth
      session << "t=#{start_time} #{stop_time}\r\n"

      if repeat_interval
        session <<
          "r=#{repeat_interval} #{active_duration} #{offsets_from_start_time}\r\n"
      end

      unless time_zones.nil? || time_zones.empty?
        session << "z=" << if time_zones.is_a? Array
          time_zones.map do |tz|
            "#{tz[:adjustment_time]} #{tz[:offset]}"
          end.join + "\r\n"
        else
          "#{time_zones[:adjustment_time]} #{time_zones[:offset]}"
        end
      end

      if encryption_method
        session << "k=#{encryption_method}"
        session << ":#{encryption_key}" if encryption_key
        session << "\r\n"
      end

      unless attributes.empty?
        attributes.each do |a|
          session << "a=#{a[:attribute]}"
          session << ":#{a[:value]}" if a[:value]
          session << "\r\n"
        end
      end

      media_sections.each do |m|
        session << "m=#{m[:media]} #{m[:port]} #{m[:protocol]} #{m[:format]}\r\n"

        if m[:attributes]
          m[:attributes].each do |a|
            session << "a=#{a[:attribute]}"
            session << ":#{a[:value]}" if a[:value]
            session << "\r\n"
          end
        end
      end

      session
    end
  end
end
