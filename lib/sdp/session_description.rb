require 'etc'
require 'socket'
require_relative '../ext/time_ntp'


class SDP
  class SessionDescription < Hash
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
          self[field_type]
        end
      end

      # Creates write accessor for the field type.  This simply writes
      # the correct Hash value and returns that.
      #
      # @param [Symbol] field_type
      def define_write_field_method(field_type)
        define_method "#{field_type}=" do |value|
          self[field_type] = value
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
    ]

    FIELDS.each do |field_type|
      field field_type
    end

    PROTOCOL_VERSION = 0

    def initialize(hash=nil)
      super()
      self[:time_zones] = []
      self[:attributes] = []
      self.protocol_version = PROTOCOL_VERSION

      if hash
        hash.each { |k, v| self[k] = v }
      end
    end

    # Seeds with some basic data.  It uses some guess work for this data, so
    # be sure to check that you're OK with it before proceeding.
    #
    # @todo Add support for stuff like connection_address = '224.2.1.1/127/3'
    def seed
      self.username = Etc.getlogin
      self.id = Time.now.to_ntp
      self.version = self.id
      self.network_type = "IN"
      self.address_type = "IP4"
      self.unicast_address = Socket.gethostname

      self.name = " "
      self.connection_network_type = self.network_type
      self.connection_address_type = self.address_type
      self.connection_address = local_ip
      self.start_time = 0
      self.stop_time = 0
    end

    # Sets the i= field and makes sure +info+ is UTF-8.
    #
    # @param [String] info The session description information.
    def information=(info)
      self[:information] = info.force_encoding('UTF-8')
    end

    # Fields required by the RFC.
    #
    # @return [Array<String>]
    def required_fields
      %w[protocol_version username id version network_type address_type
        unicast_address name start_time stop_time]
    end

    # Checks to see if it has connection fields set.
    #
    # @return [Boolean]
    def has_connection_fields?
      !!(connection_network_type && connection_address_type &&
        connection_address)
    end

    def valid?
      errors.empty?
    end

    def to_s
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

      warn "Called #to_s on an invalid #{self.class}" unless valid?

      session
    end

    # Checks to see if any required fields are not set.
    #
    # @return [Array] The list of unset fields that need to be set.
    def errors
      errors = []
      required_fields.each do |attrib|
        errors << attrib unless self.send(attrib)
      end

      self.each do |k, v|
        if v.nil? || v.to_s.empty?
          errors << k
        end
      end

      unless has_connection_fields?
        connection_errors = []

        connection_fields.each do |attrib|
          connection_errors << attrib unless self.send(attrib)
        end

        errors += connection_errors
      end

      errors
    end

    private

    # Fields that make up the connection line.
    #
    # @return [Array<String>]
    def connection_fields
      %w[connection_network_type connection_address_type connection_address]
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

    # Gets the local IP address.
    #
    # @return [String] The IP address.
    def local_ip
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end
  end
end
