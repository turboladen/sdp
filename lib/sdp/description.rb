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
      def field(field_type)
        case field_type
        when :time_zones
          define_method :time_zones do
            self[:session_section][:time_zones]
          end

          define_method "#{field_type}<<" do |value|
            self[:session_section][:time_zones] << value
          end
        when :attributes
          define_method :attributes do
            self[:session_section][:attributes]
          end

          define_method "#{field_type}<<" do |value|
            self[:session_section][:attributes] << value
          end
        when :media_sections
          define_method :media_sections do
            self[:media_sections]
          end

          define_method "#{field_type}<<" do |value|
            self[:media_sections] << value
          end
        else
          define_method field_type do
            self[:session_section][field_type.to_sym]
          end

          define_method "#{field_type}=" do |value|
            self[:session_section][field_type.to_sym] = value
          end
        end
      end
    end

    field :protocol_version
    field :username
    field :id
    field :version
    field :network_type
    field :address_type
    field :unicast_address
    field :name
    field :information
    field :uri
    field :email_address
    field :phone_number
    field :connection_address
    field :bandwidth_type
    field :bandwidth
    field :start_time
    field :stop_time
    field :repeat_interval
    field :active_duration
    field :offsets_from_start_time
    field :time_zones
    field :encryption_method
    field :encryption_key
    field :attributes
    field :media_sections

    # @param [Hash] session_as_hash Pass this in to use these values instead
    # of building your own from scratch.
    def initialize(session_as_hash=nil)
      if session_as_hash.nil?
        self[:session_section] = {}
        self[:session_section][:time_zones] = []
        self[:session_section][:attributes] = []
        self[:media_sections] = []
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

      self.send :protocol_version=, SDP::PROTOCOL_VERSION
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

      true
    end
  end
end
