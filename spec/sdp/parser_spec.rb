require File.dirname(__FILE__) + '/../spec_helper'
require 'sdp/parser'
require 'base64'

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

    it "other combinations" do
      sdps = [
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\na=recvonly\na=bobo:the clown\nm=video 49170/2 RTP/AVP 31\na=hotness\na=attribute2:do stuff\nm=audio 12335 RTP/AVP 99\na=make:it now\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\na=recvonly\na=bobo:the clown\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=prompt\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n\k=clear:password\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h 2898848070 0\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\nz=2882844526 -1h\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\nr=7d 1h 0 25h\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\nt=11111 22222\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\nb=CT:1000\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\nc=IN IP4 224.5.234.22/24\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\np=+1 555 123 0987\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\ne=bob@thing.com (Bob!)\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\nu=http://bobo.net/thispdf.pdf\n",
       "v=1\no=steve 1234 5555 IN IP4 123.33.22.123\ns=This is a test session\ni=And here's some info\n"
      ]

      sdps.each do |sdp|
        lambda { @parser.parse sdp }.should_not raise_error
      end
    end

    it "alternate email address" do
      sdp = "e=Jane Doe <j.doe@example.com>\r\n"
      sdp_hash = @parser.parse sdp
      sdp_hash[:session_section][:email_address].should == "Jane Doe <j.doe@example.com>"
    end

    it "connection data that uses TTL value" do
      sdp = "c=IN IP4 224.2.36.42/127\r\n"
      sdp_hash = @parser.parse sdp
      sdp_hash[:session_section][:connection_address].should == "224.2.36.42/127"
    end

    it "connection data that uses IPv6 and address count" do
      sdp = "c=IN IP6 FF15::101/3\r\n"
      sdp_hash = @parser.parse sdp
      sdp_hash[:session_section][:connection_address].should == "FF15::101/3"
    end

    it "repeat times in seconds" do
      sdp = "r=604800 3600 0 90000\r\n"
      sdp_hash = @parser.parse sdp
      sdp_hash[:session_section][:repeat_interval].should == "604800"
      sdp_hash[:session_section][:active_duration].should == "3600"
      sdp_hash[:session_section][:offsets_from_start_time].should == "0 90000"
    end

    it "time zones" do
      sdp = "z=2882844526 -1h 2898848070 0\r\n"
      sdp_hash = @parser.parse sdp
      sdp_hash[:session_section][:time_zones].first[:adjustment_time].should == "2882844526"
      sdp_hash[:session_section][:time_zones].first[:offset].should == "-1h"
      sdp_hash[:session_section][:time_zones].last[:adjustment_time].should == "2898848070"
      sdp_hash[:session_section][:time_zones].last[:offset].should == "0"
    end

    context "encryption keys" do
      it "clear" do
        sdp = "k=clear:password\r\n"
        sdp_hash = @parser.parse sdp
        sdp_hash[:session_section][:encryption_method].should == "clear"
        sdp_hash[:session_section][:encryption_key].should == "password"
      end
      
      it "base64" do
        # #encode64 adds newlines every 60 chars; remove them--they're unnecessary
        password = Base64.encode64('password').gsub("\n", '')
        sdp = "k=base64:#{password}\r\n"
        sdp_hash = @parser.parse sdp
        sdp_hash[:session_section][:encryption_method].should == "base64"
        sdp_hash[:session_section][:encryption_key].should == password
      end
      
      it "uri" do
        uri = "http://aserver.com/thing.pdf"
        sdp = "k=uri:#{uri}\r\n"
        sdp_hash = @parser.parse sdp
        sdp_hash[:session_section][:encryption_method].should == "uri"
        sdp_hash[:session_section][:encryption_key].should == uri
      end
      
      it "prompt" do
        sdp = "k=prompt\r\n"
        sdp_hash = @parser.parse sdp
        sdp_hash[:session_section][:encryption_method].should == "prompt"
        sdp_hash[:session_section][:encryption_key].should be_nil
      end
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
