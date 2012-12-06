require_relative 'runtime_error'
Dir["#{File.dirname(__FILE__)}/field_types/*.rb"].each { |f| require f }
require_relative '../ext/string_snake_case'


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
    def add_field(field)
      if field.is_a? String
        klass = klass_from_prefix(field[0])
        new_field = klass.new(field)
        @fields << new_field
      elsif field.is_a? Hash
        klass = klass_from_hash(field)
        new_field = klass.new(field)
        @fields << new_field
      elsif field.kind_of? SDP::Field
        @fields << field
      else
        raise SDP::RuntimeError,
          "Can't add a #{field.class} as a field"
      end
    end

    # Adds a new group of SDP description field and value combo.  The field
    # can be added by passing in a String, a Hash, or the SDP::Field.
    #
    # @param [String,Hash,SDP::FieldGroup] group
    def add_group(group)
      if group.is_a? String
        group.each_line do |line|
          klass = klass_from_prefix(line[0])
          new_group = klass.new(line)
          @groups << new_group
        end
      elsif group.is_a? Hash
        klass = klass_from_hash(group)
        new_group = klass.new(group)
        @groups << new_group
      elsif group.kind_of? SDP::FieldGroup
        @groups << group
      else
        raise SDP::RuntimeError,
          "Can't add a #{field.class} as a group"
      end
    end

    # @todo Sorting lines based on spec order
    def to_s
      s = @fields.map(&:to_s).join
      s << @groups.map(&:to_s).join

      s
    end

    # @yield [SDP::Field, SDP::FieldGroup]
    def each
      items = @fields + @groups

      items.each do |item|
        yield item if block_given?
      end
    end

    # @yield [SDP::Field]
    def each_field
      @fields.each do |field|
        yield field if block_given?
      end
    end

    # @yield [SDP::FieldGroup]
    def each_group
      @groups.each do |group|
        yield group if block_given?
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

    private

    # Finds the Field class that matches the +prefix+.
    #
    # @param [String] prefix The 1-char String that represents a Field.
    # @return [Class] The SDP::FieldTypes class that matches the prefix.
    def klass_from_prefix(prefix)
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
    def klass_from_hash(hash)
      SDP::FieldTypes.constants.each do |field_type|
        field_type_hash_key = field_type.to_s.snake_case.to_sym

        if hash.keys.first == field_type_hash_key
          return SDP::FieldTypes.const_get field_type
        end
      end

      nil
    end
  end
end
