require 'parslet'

class SDPDescription < Parslet::Parser
  # All of the fields
  rule(:version) { str('v=') >> field_value.as(:protocol_version) >> eol }

  rule(:origin) do
    str('o=') >> field_value.as(:username) >> space >> field_value.as(:session_id) >> space >>
    field_value.as(:session_version) >> space >> field_value.as(:network_type) >> space >>
    field_value.as(:address_type) >> space >> field_value.as(:unicast_address) >> eol
  end

  rule(:session_name)        { str('s=') >> field_value_string.as(:session_name) >> eol }
  rule(:session_information) { str('i=') >> field_value_string.as(:session_information) >> eol }
  rule(:uri)            { str('u=') >> field_value.as(:uri) >> eol }
  rule(:email_address)  { str('e=') >> field_value_string.as(:email_address) >> eol }
  rule(:phone_number)   { str('p=') >> field_value_string.as(:phone_number) >> eol }
  rule(:connection_data) do
    str('c=') >> field_value >> space >> field_value >> space >>
    field_value.as(:connection_address) >> eol
  end

  rule(:bandwidth) do
    str('b=') >> match('[\w]').repeat(2).as(:bandwidth_type) >> str(':') >>
    field_value.as(:bandwidth) >> eol
  end

  rule(:timing) do
    str('t=') >> field_value.as(:start_time) >> space >> field_value.as(:stop_time) >> eol
  end

  rule(:repeat_times) do
    str('r=') >> field_value.as(:repeat_interval) >> space >> field_value.as(:active_duration) >>
    space >> field_value_string.as(:offsets_from_start_time) >> eol
  end

  rule(:time_zone_group) do
    field_value.as(:time_zone_adjustment) >> space >> field_value.as(:time_zone_offset)
  end
  rule(:time_zones) do
    str('z=') >> (time_zone_group >> (space >> time_zone_group).repeat).as(:time_zones) >> eol
  end
  
  rule(:encryption_keys) do
    str('k=') >> match('[\w]').repeat.as(:encryption_method) >> (str(':') >>
      field_value.as(:encryption_key)).maybe >> eol
  end

  rule(:attribute) do
    str('a=') >> match('[\w]').repeat.as(:attribute) >> (str(':') >>
      field_value_string.as(:value)).maybe >> eol
  end
  
  rule(:media_description) do
    str('m=') >> field_value.as(:media) >> space >> field_value.as(:port) >>
      space >> field_value.as(:protocol) >> space >> field_value.as(:format) >> eol
  end

  # Generics
  rule(:space)          { match('[ ]').repeat(1) }
  rule(:eol)            { match('[\r]').maybe >> match('[\n]') }
  rule(:field_value)    { match('\S').repeat }
  rule(:field_value_string) { match('[^\r\n]').repeat }

  # The SDP description
  rule(:session_section) do
    version >> origin >> session_name >> 
      (session_information.maybe >> uri.maybe >> email_address.maybe >> phone_number.maybe >>
      connection_data.maybe >> bandwidth.maybe) >>
      timing.maybe >> repeat_times.maybe >> time_zones.maybe >> encryption_keys.maybe >>
      attribute.repeat.as(:attributes)
  end

  rule(:media_section) do
    media_description >> attribute.repeat(0).as(:attributes)
  end

  rule(:description) do
    session_section.as(:session_section) >> media_section.repeat.as(:media_sections)
  end
  
  root :description
end


=begin
s = SDPDescription.new
require 'ap'
ap s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\na=recvonly\na=bobo:the clown\nm=video 49170/2 RTP/AVP 31\na=hotness\na=attribute2:do stuff\nm=audio 12335 RTP/AVP 99\na=make:it now\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\na=recvonly\na=bobo:the clown\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=clear:password\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\n"
p s.parse "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\nt=11111 22222\n"

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