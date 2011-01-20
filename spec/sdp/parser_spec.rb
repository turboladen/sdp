require File.dirname(__FILE__) + '/../spec_helper'
require 'sdp/parser'

describe SDP::Parser do
  before :each do
    @parser = SDP::Parser.new
  end

  context "does NOT raise when missing required values" do
    it "version" do
      lambda do
        @parser.parse "o=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\nt=11111 22222\n"
      end.should_not raise_error Parslet::ParseFailed
    end

    it "origin" do
      lambda do
        @parser.parse "v=0\ns=This is a test session\nt=11111 22222\n"
      end.should_not raise_error Parslet::ParseFailed
    end

    it "name" do
      lambda do
        @parser.parse "v=0\no=steve 1234 5555 IN IP4 123.33.22.123\nt=11111 22222\n"
      end.should_not raise_error Parslet::ParseFailed
    end

    it "timing" do
      lambda do
        @parser.parse "v=0\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\n"
      end.should_not raise_error Parslet::ParseFailed
    end
  end

  context "parses" do
    it "required values" do
      sdp = "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\nt=11111 22222\nm=audio 49170 RTP/AVP 0\n"
      lambda { @parser.parse sdp }.should_not raise_error
      sdp_hash = @parser.parse sdp
      sdp_hash.should == { 
        :session_section => {
          :protocol_version=>"1",
          :username=>"steve",
          :id=>"1234",
          :version=>"5555",
          :network_type=>"IN",
          :address_type=>"IP4",
          :unicast_address=>"123.33.22.123",
          :name=>"This is a test session",
          :start_time=>"11111",
          :stop_time=>"22222"
          }, 
        :media_sections=>[
          { :media=>"audio", :port=>"49170", :protocol=>"RTP/AVP", :format=>"0" }
        ]
      }
    end
  end
  
  context "parses EOLs" do
    it "parses \\r\\n" do
      sdp = "v=123\r\n"
      lambda { @parser.parse sdp }.should_not raise_error
      sdp_hash = @parser.parse sdp
      sdp_hash[:session_section][:protocol_version].should == "123"
    end

    it "parses \\n" do
      sdp = "v=456\n"
      lambda { @parser.parse sdp }.should_not raise_error
      sdp_hash = @parser.parse sdp
      sdp_hash[:session_section][:protocol_version].should == "456"
    end
  end
end
=begin
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
