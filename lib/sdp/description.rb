require_relative 'field'
require_relative 'group'
require_relative 'logger'
require_relative 'runtime_error'

Dir["#{File.dirname(__FILE__)}/field_types/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/groups/*.rb"].each { |f| require f }

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
  class Description < Group
    include LogSwitch::Mixin

    allowed_field_types
    required_field_types
    allowed_group_types :session_description, :media_description
    required_group_types :session_description
    line_order :session_description, :media_description

    def self.parse(text)
      description = new

      text.each_line do |line|
        parse_line(line, description)
      end

      diff(text, description.to_s)

      description
    end

    def seed
      add_group(:session_description) unless has_field?(:session_description)

      super
    end

    def errors
      errors = super()

      unless has_connection_data?
        errors[:fields] ||= []
        errors[:fields] << :connection_data
      end

      errors
    end

    private

    def has_connection_data?
      if self.session_description.has_field?(:connection_data)
        log "Session description has connection_data field"
        return true
      end

      if self.has_group?(:media_description)
        groups(:media_description).all? do |group|
          result = group.has_field?(:connection_data)
          log "Group #{group.sdp_type} has connection data: #{result}"
          result
        end
      else
        log "Session description nor media descriptions had connection data"
        false
      end
    end

    def self.parse_line(line, description)
      case line[0]
      when "v"
        description.add_group :session_description
      when "t"
        description.session_description.add_group :time_description
        description.session_description.time_descriptions.last.add_field(line)

        return
      when "r"
        description.session_description.time_descriptions.last.add_field(line)
        return
      when "m"
        description.add_group :media_description
      end

      current_group = description.groups.last

      if current_group.nil?
        raise SDP::ParseError,
          "SDP text is missing the required field for starting a new section"
      end

      current_group.add_field(line)
    end

    def self.diff(one, two)
      parsed_set = one.to_s.split("\n").to_set
      original_set = two.split("\n").to_set
      difference = parsed_set ^ original_set

      unless difference.empty?
        message = "**********************************************************\n"
        message << "The parsed description does not match the original.\n"
        message << "This is probably a parser bug.  Differences in lines:\n"
        difference.each { |d| message << "#{d}\n" }
        message << "**********************************************************\n"
        warn message
      end
    end

  end
end
