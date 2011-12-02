require File.expand_path(File.dirname(__FILE__) + '/../sdp')
require 'parslet'

# Class for parsing SDP description text, ideally when receiving as some sort
# of client that uses SDP for describing the session for that protocol.
#
# This parser _could_ raise an error when not finding a required SDP field, but
# was instead designed to not do so.  For example, if the parser parses the
# text from an SDP description, and that text is missing the Timing field (t=),
# the RFC 4566 implies that this description isn't valid (because that field is
# required).  Instead ofraising an exception, the parser lets the
# SDP::Description class deal with this.
#
# Also, an object of this class parses key/value pairs, where, as a by-product
# of using +Parslet+, values end up being +Parslet::Slice+ objects.  It's worth
# pointing out that while those are not Strings, they mostly behave like
# Strings.  See the Parslet docs for more info.
class SDP::Parser < Parslet::Parser
  # All of the fields
  rule(:version) { str('v=') >> field_value.as(:protocol_version) >> eol }

  rule(:origin) do
    str('o=') >> field_value.as(:username) >> space >>
      field_value.as(:id) >> space >>
      field_value.as(:version) >> space >>
      field_value.as(:network_type) >> space >>
      field_value.as(:address_type) >> space >>
      field_value.as(:unicast_address) >> eol
  end

  rule(:session_name) { str('s=') >> field_value_string.as(:name) >> eol }

  rule(:information) do
    str('i=') >> field_value_string.as(:information) >> eol
  end

  rule(:uri)  { str('u=') >> field_value.as(:uri) >> eol }

  rule(:email_address) do
    str('e=') >> field_value_string.as(:email_address) >> eol
  end

  rule(:phone_number) do
    str('p=') >> field_value_string.as(:phone_number) >> eol
  end

  rule(:connection_data) do
    str('c=') >>
      field_value.as(:connection_network_type) >> space >>
      field_value.as(:connection_address_type) >> space >>
      field_value.as(:connection_address) >> eol
  end

  rule(:bandwidth) do
    str('b=') >> match('[\w]').repeat(2).as(:bandwidth_type) >> str(':') >>
      field_value.as(:bandwidth) >> eol
  end

  rule(:timing) do
    str('t=') >> field_value.as(:start_time) >> space >>
      field_value.as(:stop_time) >> eol
  end

  rule(:repeat_times) do
    str('r=') >> field_value.as(:repeat_interval) >> space >>
      field_value.as(:active_duration) >>
      space >> field_value_string.as(:offsets_from_start_time) >> eol
  end

  rule(:time_zone_group) do
    field_value.as(:adjustment_time) >> space >> field_value.as(:offset)
  end

  rule(:time_zones) do
    str('z=') >> (time_zone_group >>
      (space >> time_zone_group).repeat).as(:time_zones) >> eol
  end

  rule(:encryption_keys) do
    str('k=') >> match('[\w]').repeat.as(:encryption_method) >>
      (str(':') >> field_value.as(:encryption_key)).maybe >> eol
  end

  rule(:attribute) do
    str('a=') >> match('[^:\r\n]').repeat(1).as(:attribute) >>
      (str(':') >> field_value_string.as(:value)).maybe >> eol
  end

  rule(:attributes) { attribute.repeat(1).as(:attributes) }

  rule(:media_description) do
    str('m=') >> field_value.as(:media) >> space >>
      field_value.as(:port) >> space >>
      field_value.as(:protocol) >> space >>
      field_value.as(:format) >> eol
  end

  # Generics
  rule(:space)          { match('[ ]').repeat(1) }
  rule(:eol)            { match('[\r]').maybe >> match('[\n]') }
  rule(:field_value)    { match('\S').repeat }
  rule(:field_value_string) { match('[^\r\n]').repeat }

  # The SDP description
  rule(:session_section) do
    version.maybe >> origin.maybe >> session_name.maybe >>
      information.maybe >> uri.maybe >> email_address.maybe >>
      phone_number.maybe >> connection_data.maybe >> bandwidth.maybe >>
      timing.maybe >> repeat_times.maybe >> time_zones.maybe >>
      encryption_keys.maybe >> attributes.maybe
  end

  rule(:media_section) do
    media_description >> information.maybe >> connection_data.maybe >>
      bandwidth.maybe >> encryption_keys.maybe >> attributes.maybe
  end

  rule(:description) do
    session_section.as(:session_section) >>
      media_section.repeat.as(:media_sections)
  end

  root :description
end
