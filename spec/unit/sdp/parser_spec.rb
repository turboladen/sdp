=begin
require 'spec_helper'
require 'sdp/parser'
require 'base64'

describe SDP::Parser do
  it "handles descriptions missing time zone field" do
    expect {
      subject.parse SDP_MISSING_TIME
    }.to_not raise_error Parslet::ParseFailed
  end

  context "parses" do
    let(:description) { REQUIRED_ONLY }

    it "required values" do
      subject.parse(description).should == {
        :session_section => {
          :protocol_version => "0",
          :username => "guy",
          :id => "1234",
          :version => "5555",
          :network_type => "IN",
          :address_type => "IP4",
          :unicast_address => "123.33.22.123",
          :name => "This is a test session",
          :connection_network_type => "IN",
          :connection_address_type => "IP4",
          :connection_address=> "0.0.0.0",
          :start_time => "11111",
          :stop_time => "22222"
          }, 
        :media_sections => []
      }
    end

    it "alternate email address" do
      sdp = "e=Jane Doe <j.doe@example.com>\r\n"
      sdp_hash = subject.parse sdp
      sdp_hash[:session_section][:email_address].should == "Jane Doe <j.doe@example.com>"
    end

    it "connection data that uses TTL value" do
      sdp = "c=IN IP4 224.2.36.42/127\r\n"
      sdp_hash = subject.parse sdp
      sdp_hash[:session_section][:connection_address].should == "224.2.36.42/127"
    end

    it "connection data that uses IPv6 and address count" do
      sdp = "c=IN IP6 FF15::101/3\r\n"
      sdp_hash = subject.parse sdp
      sdp_hash[:session_section][:connection_address].should == "FF15::101/3"
    end

    it "repeat times in seconds" do
      sdp = "r=604800 3600 0 90000\r\n"
      sdp_hash = subject.parse sdp
      sdp_hash[:session_section][:repeat_interval].should == "604800"
      sdp_hash[:session_section][:active_duration].should == "3600"
      sdp_hash[:session_section][:offsets_from_start_time].should == "0 90000"
    end

    it "time zones" do
      sdp = "z=2882844526 -1h 2898848070 0\r\n"
      sdp_hash = subject.parse sdp
      sdp_hash[:session_section][:time_zones].first[:adjustment_time].should == "2882844526"
      sdp_hash[:session_section][:time_zones].first[:offset].should == "-1h"
      sdp_hash[:session_section][:time_zones].last[:adjustment_time].should == "2898848070"
      sdp_hash[:session_section][:time_zones].last[:offset].should == "0"
    end

    context "encryption keys" do
      it "clear" do
        sdp = "k=clear:password\r\n"
        sdp_hash = subject.parse sdp
        sdp_hash[:session_section][:encryption_method].should == "clear"
        sdp_hash[:session_section][:encryption_key].should == "password"
      end
      
      it "base64" do
        # #encode64 adds newlines every 60 chars; remove them--they're unnecessary
        password = Base64.encode64('password').gsub("\n", '')
        sdp = "k=base64:#{password}\r\n"
        sdp_hash = subject.parse sdp
        sdp_hash[:session_section][:encryption_method].should == "base64"
        sdp_hash[:session_section][:encryption_key].should == password
      end
      
      it "uri" do
        uri = "http://aserver.com/thing.pdf"
        sdp = "k=uri:#{uri}\r\n"
        sdp_hash = subject.parse sdp
        sdp_hash[:session_section][:encryption_method].should == "uri"
        sdp_hash[:session_section][:encryption_key].should == uri
      end
      
      it "prompt" do
        sdp = "k=prompt\r\n"
        sdp_hash = subject.parse sdp
        sdp_hash[:session_section][:encryption_method].should == "prompt"
        sdp_hash[:session_section][:encryption_key].should be_nil
      end
    end
  end

  context "attributes" do
    it "attribute" do
      sdp = "a=x-qt-text-cmt:Orban Opticodec-PC\r\n"
      sdp_hash = subject.parse sdp
      sdp_hash[:session_section][:attributes].first[:attribute].should ==
        "x-qt-text-cmt"
      sdp_hash[:session_section][:attributes].first[:value].should ==
        "Orban Opticodec-PC"
    end
  end
  
  context "media sections" do
    it "all possible fields in 1 section" do
      sdp = "m=audio 0 RTP/AVP 96\r\ni=Test info\r\nc=IN IP4 0.0.0.0\r\nb=AS:40\r\nk=prompt\r\na=rtpmap:96 MP4A-LATM/44100/2\r\na=fmtp:96 cpresent=0;config=400027200000\r\n"
      sdp_hash = subject.parse sdp
      first_media_section = sdp_hash[:media_sections].first
      first_media_section[:media].should == "audio"
      first_media_section[:port].should == "0"
      first_media_section[:protocol].should == "RTP/AVP"
      first_media_section[:format].should == "96"
      first_media_section[:information].should == "Test info"
      first_media_section[:connection_network_type].should == "IN"
      first_media_section[:connection_address_type].should == "IP4"
      first_media_section[:connection_address].should == "0.0.0.0"
      first_media_section[:bandwidth_type].should == "AS"
      first_media_section[:bandwidth].should == "40"
      first_media_section[:encryption_method].should == "prompt"
      first_media_section[:attributes].first[:attribute].should == "rtpmap"
      first_media_section[:attributes].first[:value].should == "96 MP4A-LATM/44100/2"
      first_media_section[:attributes].last[:attribute].should == "fmtp"
      first_media_section[:attributes].last[:value].should == "96 cpresent=0;config=400027200000"
    end
  end

  context "parses EOLs" do
    it "parses \\r\\n" do
      sdp = "v=123\r\n"
      lambda { subject.parse sdp }.should_not raise_error
      sdp_hash = subject.parse sdp
      sdp_hash[:session_section][:protocol_version].should == "123"
    end

    it "parses \\n" do
      sdp = "v=456\n"
      lambda { subject.parse sdp }.should_not raise_error
      sdp_hash = subject.parse sdp
      sdp_hash[:session_section][:protocol_version].should == "456"
    end
  end
end
=end
