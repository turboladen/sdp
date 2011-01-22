require 'erb'

class SDP
  PROTOCOL_VERSION = 0

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
      # in the Hash key.
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
    # of building your own from scratch.
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

    # Turns the current SDP::Description object into the SDP description,
    # ready to be used.
    #
    # @return [String] The SDP description.
    def to_s
      template = File.read(File.dirname(__FILE__) + "/session_template.erb")

      sdp = ERB.new(template, 0, "%<>")
      sdp.result(get_binding)
    end

    # Checks to see if the fields set in the current object will yield an SDP
    # description that meets the RFC 4566 spec.
    #
    # @return [Boolean] true if the object will meet spec; false if not.
    def valid?
      return false unless protocol_version && username && id && version &&
        network_type && address_type && unicast_address && name &&
        start_time && stop_time && !media_sections.empty?

      true
    end

    #--------------------------------------------------------------------------
    # PRIVATES!
    private

    # @return [Binding] Values for this object for ERB to use.
    def get_binding
      binding
    end

    # @raise [SDP::RuntimeError] If not given a Hash.
    def validate_init_value value
      unless value.class == Hash
        message = "Must pass a Hash in on initialize.  You passed in a #{value.class}."
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
  end
end
