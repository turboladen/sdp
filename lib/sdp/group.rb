require 'set'
require_relative 'base'
require_relative 'group_dsl'
require_relative 'logger'
require_relative 'runtime_error'
require_relative '../ext/string_case_conversions'
require_relative '../ext/class_name_to_symbol'

Dir["#{File.dirname(__FILE__)}/fields/*.rb"].each { |f| require f }


class SDP

  # Useful for grouping fields together for SDP descriptions.  Many SDP fields
  # can depend on other fields in certain cases (i.e. media sections, timing
  # fields, attributes, etc.).  This allows grouping those fields together and
  # dealing with them as a group; in essence, it's a container for common
  # fields.
  #
  # But not only can you group fields--you can group groups as well.  A full
  # SDP description can be made up of a session section and multiple media
  # sections, where each one of those sections can have fields that depend on
  # other fields.
  #
  # For example, take the following description:
  #
  #   v=0
  #   o=jdoe 2890844526 2890842807 IN IP4 10.47.16.5
  #   s=SDP Seminar
  #   i=A Seminar on the session description protocol
  #   u=http://www.example.com/seminars/sdp.pdf
  #   e=j.doe@example.com (Jane Doe)
  #   c=IN IP4 224.2.17.12/127
  #   t=2873397496 2873404696
  #   a=recvonly
  #   m=audio 49170 RTP/AVP 0
  #   m=video 51372 RTP/AVP 99
  #   a=rtpmap:99 h263-1998/90000
  #
  # The whole description can be a Group.  The lines from "v=0" to
  # "a=recvonly" could be another Group inside the main Group to
  # represent the session section.  The first "m=" line could be treated either
  # as a Group or just a Field, depending on whether or not you planned on
  # adding fields for that media section.  The last "m=" line through the end
  # would be another Group.
  #
  # There are a number of ways you could use FieldGroups to build the
  # description above; here is one way.
  #
  # @example Build from scratch
  #   description = SDP::Group.new
  #
  #   session_section = SDP::Group.new
  #   audio_section = SDP::Group.new
  #   video_section = SDP::Group.new
  #
  #   description.add_group(session_section)
  #   description.add_group(audio_section)
  #   description.add_group(video_section)
  #
  #   # Add a field using a Hash
  #   session_section.add_field(protocol_version: 0)
  #
  #   # Add a field using a String
  #   session_section.add_field("o=jdoe 2890844526 2890842807 IN IP4 10.47.16.5")
  #
  #   # Add a field using a SDP::Field
  #   session_name = SDP::Fields::SessionName.new
  #   session_name.session_name = "SDP Seminar"
  #   session_section.add_field(session_name)
  #
  #   session_section.add_field("i=A Seminar on the session descripton protocol")
  #   session_section.add_field("u=http://www.example.com/seminars/sdp.pdf")
  #   session_section.add_field("e=j.doe@example.com (Jane Doe)")
  #   session_section.add_field("c=IN IP4 224.2.17.12/127")
  #   session_section.add_field("t=2873397496 2873404696")
  #   session_section.add_field("a=recvonly")
  class Group < Base
    include SDP::GroupDSL
    include LogSwitch::Mixin

    def initialize
      @fields = []
      @groups = []
    end

    # Adds a new (single) SDP description field and value combo.  The field
    # can be added by passing in a String, a Hash, or the SDP::Field.
    #
    # @param [String,Hash,SDP::Field] field
    # @return [Array<SDP::Field>] The updated +fields+ list.
    # @todo Determine if the Hash interface is needed...
    def add_field(field)
      field_object = if field.is_a? String
        SDP::Field.new_from_string(field)
      elsif field.is_a? Hash
        SDP::Field.new_from_hash(field)
      elsif field.is_a? Symbol
        SDP::Field.new_from_type(field)
      elsif field.kind_of? SDP::Field
        field
      else
        raise SDP::RuntimeError,
          "Can't add a #{field.class} as a field"
      end

      check_allowed_field(field, field_object)

      if field_object.kind_of? SDP::Field
        @fields << field_object
      else
        raise SDP::RuntimeError, "Can't add #{field_object} to fields!"
      end

      define_field_accessor(@fields.last)

      log "Added field type '#{field_object.sdp_type}' to a '#{sdp_type}' group"
      @fields
    end

    def has_field?(field)
      if field.is_a? Symbol
        @fields.any? { |f| f.sdp_type == field }
      elsif field.kind_of? SDP::Field
        @fields.any? { |f| f.class == field.class }
      end
    end

    # Adds a new group of SDP description field and value combo.  The field
    # can be added by passing in a String, a Hash, a Symbol, or the SDP::Field.
    #
    # @example From a String
    #   group = Group.new
    #   group.add_group("o=joe 12345 9887 IN IP4 10.20.30.40")
    #
    # @example From a Hash
    #   group = Group.new
    #   origin = {
    #     :origin => {
    #       :username => "joe",
    #       :session_id => 12345,
    #       :session_version => 9887,
    #       :network_type => "IN",
    #       :address_type => "IP4",
    #       :unicast_address => "10.20.30.40"
    #       }
    #     }
    #   group.add_group(origin)
    #
    # @example From a Symbol
    #   group = Group.new
    #   group.add_group(:session_description)
    #
    # @param [String,Hash,SDP::Group] group
    # @todo Determine if the Hash interface is needed...
    def add_group(group)
      if group.is_a? Hash
        new_group = SDP::Group.new_from_hash(group)
        check_allowed_group(new_group.class)
        @groups << new_group

        define_group_accessor(@groups.last)
        log "Added group type '#{@groups.last.sdp_type}' to #{sdp_type}"
      elsif group.is_a? Symbol
        new_group = SDP::Group.new_from_type(group)
        check_allowed_group(new_group.class)
        @groups << new_group
        define_group_accessor(@groups.last)
        log "Added group type '#{@groups.last.sdp_type}' to #{sdp_type}"
      elsif group.kind_of? SDP::Group
        check_allowed_group(group.class)
        @groups << group

        define_group_accessor(@groups.last)
        log "Added group type '#{@groups.last.sdp_type}' to #{sdp_type}"
      else
        raise SDP::RuntimeError,
          "Can't add a #{field.class} as a group"
      end

      @groups
    end

    def has_group?(group)
      if group.is_a? Symbol
        @groups.any? { |g| g.sdp_type == group }
      elsif group.kind_of? SDP::Field
        @groups.any? { |g| g.class == group.class }
      end
    end

    def to_s
      super

      sdp_sort.map(&:to_s).join
    end

    def to_hash
      fields_hash = @fields.inject({}) do |result, field|
        result.merge!(field.to_hash)

        result
      end

      groups_hash = @groups.inject({}) do |result, group|
        result.merge!(group.to_hash)

        result
      end

      fields_hash.merge(groups_hash)
    end

    def sdp_sort
      if settings.line_order.empty?
        warn "#sdp_sort called on a #{self.class} without an order defined"
        return
      end

      sorted_list = ::Set.new
      fields = @fields.dup
      groups = @groups.dup

      until fields.empty? && groups.empty?
        settings.line_order.each do |sdp_type_name|
          field = fields.find { |field| field.sdp_type == sdp_type_name }

          if field
            sorted_list << fields.delete(field)
            log "Sorted list << Field #{field.sdp_type}"
          end

          next if field

          group = groups.find { |g| g.sdp_type == sdp_type_name }

          if group
            sorted_list << groups.delete(group)
            log "Sorted list << Group #{group.sdp_type}"
          end
        end
      end

      log "Sorted list:"; sorted_list.each { |s| log s.sdp_type }; log ""

      sorted_list
    end

    def groups(type=nil)
      return @groups unless type

      @groups.find_all { |group| group.sdp_type == type }
    end

    def fields(type=nil)
      return @fields unless type

      @fields.find_all { |field| field.sdp_type == type }
    end

    def added_field_types
      @fields.map do |field|
        field.sdp_type
      end
    end

    def added_group_types
      @groups.map do |group|
        group.sdp_type
      end
    end

    # @yield [SDP::Field, SDP::Group]
    def each_field
      lines = @fields.dup

      lines << @groups.map do |group|
        group.fields + group.groups
      end

      lines.flatten.each do |item|
        yield item if block_given?
      end
    end

    def seed
      @fields.each(&:seed)
      @groups.each(&:seed)

      self
    end

    # @return [Hash]
    def errors
      errors = {}
      missing_fields = settings.required_field_types - added_field_types
      errors[:fields] = missing_fields unless missing_fields.empty?

      missing_groups  = settings.required_group_types - added_group_types
      errors[:groups] = missing_groups unless missing_groups.empty?

      @groups.each do |group|
        child_group_errors = group.errors

        if child_group_errors && !child_group_errors.empty?
          errors[:groups] ||= []
          errors[:groups] << { group.sdp_type => child_group_errors }
        end
      end

      errors
    end

    private

    def define_field_accessor(new_field)
      if new_field.settings.allows_multiple?
        define_singleton_method("#{new_field.sdp_type}s") do
          fields(new_field.sdp_type)
        end
      else
        define_singleton_method(new_field.sdp_type) do
          fields(new_field.sdp_type).first
        end
      end
    end

    def define_group_accessor(new_group)
      if new_group.settings.allows_multiple?
        define_singleton_method("#{new_group.sdp_type}s") do
          groups(new_group.sdp_type)
        end
      else
        define_singleton_method(new_group.sdp_type) do
          groups(new_group.sdp_type).first
        end
      end
    end

    def check_allowed_group(klass)
      unless settings.allowed_group_types.include? klass.sdp_type
        raise SDP::RuntimeError,
          "#{klass} groups can't be added to #{self.class}s"
      end

      if !klass.allows_multiple? && has_group?(klass.sdp_type)
        message = "#{klass} fields don't allow multiples and "
        message << "one is already defined."
        raise SDP::RuntimeError, message
      end
    end

    def check_allowed_field(field, field_object)
      unless settings.allowed_field_types.include? field_object.sdp_type
        message = "#{field_object.class} fields can't be added to #{self.class}s"
        message << "\nField object: #{self}\n"
        message << "Field: #{field}"
        raise SDP::RuntimeError, message
      end

      if !field_object.settings.allows_multiple? && has_field?(field_object)
        message = "#{field_object.class} fields don't allow multiples and "
        message << "one is already defined."
        raise SDP::RuntimeError, message
      end
    end
  end
end

class SDP
  class Group
    def self.new_from_type(sdp_type)
      SDP::Groups.const_get(sdp_type.to_s.camel_case).new
    end

    # Creates a Group that defines values based on the +hash+.
    #
    # @param [Hash] hash
    # @return [SDP::Group] The SDP::Groups object that matches the hash.
    def self.new_from_hash(hash)
      klass = SDP::Groups.constants.find do |group_class|
        sdp_type = SDP::Groups.const_get(group_class).sdp_type
        hash.keys.first = sdp_type
      end

      SDP::Groups.const_get(klass).new(hash)
    end
  end
end
