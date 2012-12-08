require 'set'
require_relative 'runtime_error'
require_relative 'field_group_dsl'
require_relative 'logger'
require_relative '../ext/string_case_conversions'
require_relative '../ext/class_name_to_symbol'

Dir["#{File.dirname(__FILE__)}/field_types/*.rb"].each { |f| require f }


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
  # The whole description can be a FieldGroup.  The lines from "v=0" to
  # "a=recvonly" could be another FieldGroup inside the main FieldGroup to
  # represent the session section.  The first "m=" line could be treated either
  # as a FieldGroup or just a Field, depending on whether or not you planned on
  # adding fields for that media section.  The last "m=" line through the end
  # would be another FieldGroup.
  #
  # There are a number of ways you could use FieldGroups to build the
  # description above; here is one way.
  #
  # @example Build from scratch
  #   description = SDP::FieldGroup.new
  #
  #   session_section = SDP::FieldGroup.new
  #   audio_section = SDP::FieldGroup.new
  #   video_section = SDP::FieldGroup.new
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
  #   session_name = SDP::FieldTypes::SessionName.new
  #   session_name.session_name = "SDP Seminar"
  #   session_section.add_field(session_name)
  #
  #   session_section.add_field("i=A Seminar on the session descripton protocol")
  #   session_section.add_field("u=http://www.example.com/seminars/sdp.pdf")
  #   session_section.add_field("e=j.doe@example.com (Jane Doe)")
  #   session_section.add_field("c=IN IP4 224.2.17.12/127")
  #   session_section.add_field("t=2873397496 2873404696")
  #   session_section.add_field("a=recvonly")
  class FieldGroup
    include SDP::FieldGroupDSL
    include LogSwitch::Mixin

    attr_reader :fields
    attr_reader :groups

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
        klass = field_klass_from_prefix(field[0])
        klass.new(field)
      elsif field.is_a? Hash
        klass = field_klass_from_hash(field)
        klass.new(field)
      elsif field.is_a? Symbol
        klass = field_klass_from_symbol(field)
        klass.new(field)
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
    #   group = FieldGroup.new
    #   group.add_group("o=joe 12345 9887 IN IP4 10.20.30.40")
    #
    # @example From a Hash
    #   group = FieldGroup.new
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
    #   group = FieldGroup.new
    #   group.add_group(:session_description)
    #
    # @param [String,Hash,SDP::FieldGroup] group
    # @todo Determine if the Hash interface is needed...
    def add_group(group)
      if group.is_a? Hash
        klass = field_klass_from_hash(group)
        check_allowed_group(klass)
        @groups << klass.new(group)

        define_group_accessor(@groups.last)
        log "Added group type '#{@groups.last.sdp_type}' to #{sdp_type}"
      elsif group.is_a? Symbol
        klass_name = klass_from_symbol(group)
        check_allowed_group(klass_name)
        @groups << klass_name.new
        define_group_accessor(@groups.last)
        log "Added group type '#{@groups.last.sdp_type}' to #{sdp_type}"
      elsif group.kind_of? SDP::FieldGroup
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
      unless valid?
        warn "#to_s called on a #{self.class} without required info added: #{errors}"
      end

      sdp_sort.map(&:to_s).join
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

    # Returns the name of the lowest level class as a snake-case Symbol.
    #
    # @example
    #   SDP::FieldTypes::TimeZoneAdjustments.sdp_type   # => :time_zone_adjustments
    #
    # @return [Symbol]
    def sdp_type
      self.class.sdp_type
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

    # @yield [SDP::Field, SDP::FieldGroup]
    def each_field
      lines = @fields.dup

      lines << @groups.map do |group|
        group.fields + group.groups
      end

      lines.flatten.each do |item|
        yield item if block_given?
      end
    end

    # This custom redefinition of #inspect is needed because of the #to_s
    # definition.
    #
    # @return [String]
    def inspect
      me = "#<#{self.class.name}:0x#{self.object_id.to_s(16)}"

      ivars = self.instance_variables.map do |variable|
        "#{variable}=#{instance_variable_get(variable).inspect}"
      end.join(' ')

      me << " #{ivars}" unless ivars.empty?
      me << ">"

      me
    end

    def seed
      @fields.each(&:seed)
      @groups.each(&:seed)

      self
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

    # @return [Boolean]
    def valid?
      errors.empty?
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

    def allows_multiple?
      self.class.allows_multiple?
    end

    private

    # Finds the Field class that matches the +prefix+.
    #
    # @param [String] prefix The 1-char String that represents a Field.
    # @return [Class] The SDP::FieldTypes class that matches the prefix.
    def field_klass_from_prefix(prefix)
      SDP::FieldTypes.constants.each do |field_type|
        klass = SDP::FieldTypes.const_get field_type

        if klass.prefix.to_s == prefix.to_s
          return klass
        end
      end

      nil
    end

    # Finds the Field class that defines values based on the +hash+.
    #
    # @param [Hash] hash
    # @return [Class] The SDP::FieldTypes class that matches the hash.
    def field_klass_from_hash(hash)
      SDP::FieldTypes.constants.each do |field_type|
        field_type_hash_key = field_type.to_s.snake_case.to_sym

        if hash.keys.first == field_type_hash_key
          return SDP::FieldTypes.const_get field_type
        end
      end

      nil
    end

    def field_klass_from_symbol(symbol)
      SDP::FieldTypes.const_get(symbol.to_s.camel_case)
    end

    def klass_from_symbol(symbol)
      begin
        SDP::FieldGroupTypes.const_get(symbol.to_s.camel_case)
      rescue NameError
        SDP::FieldTypes.const_get(symbol.to_s.camel_case)
      end
    end

    def define_field_accessor(new_field)
      if new_field.allows_multiple?
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
      if new_group.allows_multiple?
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

      if !field_object.allows_multiple? && has_field?(field_object)
        message = "#{field_object.class} fields don't allow multiples and "
        message << "one is already defined."
        raise SDP::RuntimeError, message
      end
    end

  end
end
