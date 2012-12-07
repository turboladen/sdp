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
    allowed_group_types :session_description, :media_description
    required_group_types :session_description
    line_order :session_description, :media_description

    def self.parse(text)
      description = new

      text.each_line do |line|
        case line[0]
        when "v"
          description.add_group :session_description
        when "t"
          description.session_description.add_group :time_description
          description.session_description.time_description.add_field(line)
          next
        when "m"
          description.add_group :media_description
        end

        current_group = if !description.groups.empty? &&
          !description.groups.last.fields.empty? &&
          description.groups.last.fields.last.prefix == :r
          description.groups[-2]
        else
          description.groups.last
        end

        current_group.add_field(line)
      end

      diff(text, description.to_s)

      description
    end

    def seed
      add_group(:session_description) unless has_field?(:session_description)

      super
    end

    private

    def self.diff(one, two)
      parsed_set = one.to_s.split(" ").to_set
      original_set = two.split(" ").to_set
      difference = parsed_set ^ original_set

      unless difference.empty?
        message = "**********************************************************\n"
        message << "The parsed description does not match the original.\n"
        message << "This is probably a parser bug.  Differences:\n"
        difference.each { |d| message << "#{d}\n" }
        message << "**********************************************************\n"
        warn message
      end
    end

  end
end
