require 'parslet'

class SDPDescription < Parslet::Parser
=begin
  rule(:field)    { match('[\w]').as(:field_type) }
  rule(:equals)   { match("=") }
  rule(:field_value) { match(/\S/).repeat.as(:value) }

  rule(:eol)      { crlf }
  rule(:crlf)     { match('[\n]') }

  rule(:space)  { match('[ ]').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:field_value_section)  { field_value >> (space >> field_value).repeat }
  rule(:field_line)  { field >> equals >> field_value_section.as(:values) }
  rule(:description) { (field_line >> eol).repeat(1) }

  root :description
=end
  rule(:version_name)   { str('v=') }
  rule(:version)        { version_name >> field_value.as(:protocol_version) }

  rule(:origin_name)    { str('o=') }
  rule(:origin) do
    origin_name >> field_value.as(:username) >> space >> field_value.as(:session_id) >> space >>
    field_value.as(:session_version) >> space >> field_value.as(:network_type) >> space >>
    field_value.as(:address_type) >> space >> field_value.as(:unicast_address)
  end

  rule(:session_name_name)   { str('s=') }
  rule(:session_name)   { session_name_name >> match('[^\n]').repeat.as(:session_name)}
  # Generics
  rule(:space)          { match('[ ]').repeat(1) }
  rule(:eol)            { match('[\n]') }
  rule(:field_value)    { match('\S').repeat }

  rule(:description)    { version >> eol >> origin >> eol >> session_name >> eol }
  root :description
end

s = SDPDescription.new
#p s.parse "v=1"
#p s.parse "v=1\n"
#p s.parse "v=1\no=steve\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\n"

=begin
string = <<-STR
v=0
o=jdoe 2890844526 2890842807 IN IP4 10.47.16.5
s=SDP Seminar
i=A Seminar on the session description protocol
u=http://www.example.com/seminars/sdp.pdf
e=j.doe@example.com (Jane Doe)
c=IN IP4 224.2.17.12/127
t=2873397496 2873404696
a=recvonly
m=audio 49170 RTP/AVP 0
m=video 51372 RTP/AVP 99
a=rtpmap:99 h263-1998/90000
STR

require 'ap'
ap s.parse string
=end
