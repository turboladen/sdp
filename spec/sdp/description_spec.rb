require File.dirname(__FILE__) + '/../spec_helper'
require 'sdp/description'
require 'base64'

describe SDP::Description do
  before :each do
    @sdp = SDP::Description.new
  end

  it "initializes with the protocol_version value set" do
    @sdp.protocol_version.should == SDP::PROTOCOL_VERSION
  end

  context "can add and retrieve fields" do
    it "protocol_version" do
      @sdp.protocol_version = 1
      @sdp.protocol_version.should == 1
    end

    it "username" do
      @sdp.username = "jdoe"
      @sdp.username.should == "jdoe"
    end

    it "id" do
      @sdp.id = 2890844526
      @sdp.id.should == 2890844526
    end

    it "version" do
      @sdp.version = 2890842807
      @sdp.version.should == 2890842807
    end

    it "network_type" do
      @sdp.network_type = :IN
      @sdp.network_type.should == :IN
    end

    it "address_type" do
      @sdp.address_type = :IP4
      @sdp.address_type.should == :IP4
    end

    it "unicast_address" do
      @sdp.unicast_address = "10.47.16.5"
      @sdp.unicast_address.should == "10.47.16.5"
    end

    it "name" do
      @sdp.name = "This is a session"
      @sdp.name.should == "This is a session"
    end

    it "name can be a ' '" do
      @sdp.name = " "
      @sdp.name.should == " "
    end

    it "information" do
      @sdp.information = "This is a session"
      @sdp.information.should == "This is a session"
    end

    it "uri" do
      @sdp.uri = "http://localhost"
      @sdp.uri.should == "http://localhost"
    end

    it "email_address" do
      @sdp.email_address = 'me@me.com'
      @sdp.email_address.should == 'me@me.com'
    end

    it "email_address in alternate form" do
      @sdp.email_address = "Jane Doe <j.doe@example.com>"
      @sdp.email_address.should == "Jane Doe <j.doe@example.com>"
    end

    it "phone_number" do
      @sdp.phone_number = "+1 555 123 4567"
      @sdp.phone_number.should == "+1 555 123 4567"
    end

    it "connection_network_type" do
      @sdp.connection_network_type = 'IN'
      @sdp.connection_network_type.should == 'IN'
    end

    it "connection_address_type" do
      @sdp.connection_address_type = 'IP4'
      @sdp.connection_address_type.should == 'IP4'
    end

    it "connection_address" do
      @sdp.connection_address = 'localhost'
      @sdp.connection_address.should == 'localhost'
    end

    it "connection_address using TTL" do
      @sdp.connection_address = "224.2.36.42/127"
      @sdp.connection_address.should == "224.2.36.42/127"
    end

    it "connection_address using IPv6 address and count" do
      @sdp.connection_address = "FF15::101/3"
      @sdp.connection_address.should == "FF15::101/3"
    end

    it "bandwidth_type" do
      @sdp.bandwidth = :CT
      @sdp.bandwidth.should == :CT
    end

    it "bandwidth" do
      @sdp.bandwidth = 100
      @sdp.bandwidth.should == 100
    end

    it "start_time" do
      @sdp.start_time = 99112299
      @sdp.start_time.should == 99112299
    end

    it "stop_time" do
      @sdp.stop_time = 99999999
      @sdp.stop_time.should == 99999999
    end
  
    it "repeat_interval" do
      @sdp.repeat_interval = 12345
      @sdp.repeat_interval.should == 12345
    end

    it "active_duration" do
      @sdp.active_duration = 12345
      @sdp.active_duration.should == 12345
    end

    it "offsets_from_start_time" do
      @sdp.offsets_from_start_time = 99
      @sdp.offsets_from_start_time.should == 99
    end
  
    context "time_zones" do
      it "one time zone" do
        new_values = { :adjustment_time => 111111,
          :offset => 99 }
        @sdp.time_zones << new_values
        @sdp.time_zones.should == [new_values]
      end

      it "two time_zones" do
        new_values1 = { :adjustment_time => 111111,
          :offset => 99 }
        new_values2 = { :adjustment_time => 222222,
          :offset => 88 }
        @sdp.time_zones << new_values1
        @sdp.time_zones << new_values2
        @sdp.time_zones.should == [new_values1, new_values2]
      end
    end
  
    context "encryption keys" do
      it "clear" do
        @sdp.encryption_method = 'clear'
        @sdp.encryption_method.should == 'clear'
        @sdp.encryption_key = 'password'
        @sdp.encryption_key.should == 'password'
      end
  
      it "base64" do
        @sdp.encryption_method = 'base64'
        @sdp.encryption_method.should == 'base64'
        enc = Base64.encode64('password')
        @sdp.encryption_key = enc
        @sdp.encryption_key.should == enc
      end
  
      it "uri" do
        @sdp.encryption_method = 'uri'
        @sdp.encryption_method.should == 'uri'
        uri = "http://aserver.com/thing.pdf"
        @sdp.encryption_key = uri
        @sdp.encryption_key.should == uri
      end
  
      it "prompt" do
        @sdp.encryption_method = 'prompt'
        @sdp.encryption_method.should == 'prompt'
        @sdp.encryption_key.should be_nil
      end
    end

    context "attributes" do
      it "one attribute with value" do
        new_values = { :attribute => 'rtpmap',
          :value => "99 h263-1998/90000" }
        @sdp.attributes << new_values
        @sdp.attributes.first.should == new_values
      end

      it "one attribute with empty value" do
        new_values = { :attribute => 'rtpmap',
          :value => "" }
        @sdp.attributes << new_values
        @sdp.attributes.first.should == new_values
      end

      it "one attribute with nil value" do
        new_values = { :attribute => 'rtpmap' }
        @sdp.attributes << new_values
        @sdp.attributes.first.should == new_values
      end

      it "two attributes" do
        new_values1 = { :attribute => 'test' }
        new_values2 = { :attribute => 'rtpmap',
          :value => "99 h263-1998/90000" }
        @sdp.attributes << new_values1
        @sdp.attributes << new_values2
        @sdp.attributes.should == [new_values1, new_values2]
      end
    end
  
    context "media_sections" do
      it "can add a basic media section" do
        new_values = { :media => 'audio',
          :port => 12345,
          :protocol => 'RTP/AVP',
          :format => 99 }
        @sdp.media_sections << new_values
        @sdp.media_sections.first.should == new_values
      end

      it "can add a basic media section with attributes" do
        new_values = { :media => 'audio',
          :port => 12345,
          :protocol => 'RTP/AVP',
          :format => 99,
          :attributes => [
            {
              :attribute => "rtpmap",
              :value => "99 h263-1998/90000"
            }
          ]
        }
        @sdp.media_sections << new_values
        @sdp.media_sections.first.should == new_values
      end

      it "can add 2 basic media sections" do
        new_values = []
        new_values << { :media => 'audio',
          :port => 12345,
          :protocol => 'RTP/AVP',
          :format => 99 }
        @sdp.media_sections << new_values[0]

        new_values << { :media => 'video',
          :port => 5678,
          :protocol => 'RTP/AVP',
          :format => 33 }
        @sdp.media_sections << new_values[1]

        @sdp.media_sections.class.should == Array
        @sdp.media_sections[0].should == new_values[0]
        @sdp.media_sections[1].should == new_values[1]
      end
    end
  end

  context "#to_s" do
    it "contains required session section values" do
      @sdp.to_s.should match /v=0/
      @sdp.to_s.should match /o=/
      @sdp.to_s.should match /s=/
      @sdp.to_s.should match /t=/
    end
  end

  context "#valid?" do
    before :each do
      @sdp = SDP::Description.new

      @sdp.protocol_version = 0
      @sdp.username = "jdoe"
      @sdp.id = 12345
      @sdp.version = 12345
      @sdp.network_type = :IN
      @sdp.address_type = :IP4
      @sdp.unicast_address = "127.0.0.1"
      @sdp.name = "This is a test"
      @sdp.start_time = 12345678
      @sdp.stop_time = 12345680
      @sdp.media_sections << { :media => "audio", :port => 123,
        :protocol => "RTP/AVP", :format => 99 }
    end

    it "is valid when all required fields have values" do
      @sdp.valid?.should be_true
    end

    it "is NOT valid when protocol_version isn't set" do
      @sdp.protocol_version = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when username isn't set" do
      @sdp.username = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when id isn't set" do
      @sdp.id = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when version isn't set" do
      @sdp.version = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when network_type isn't set" do
      @sdp.network_type = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when address_type isn't set" do
      @sdp.address_type = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when unicast_address isn't set" do
      @sdp.unicast_address = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when name isn't set" do
      @sdp.name = nil
      @sdp.valid?.should be_false
    end

    it "is valid when name is ' '" do
      @sdp.name = ' '
      @sdp.valid?.should be_true
    end

    it "is NOT valid when start_time isn't set" do
      @sdp.start_time = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when stop_time isn't set" do
      @sdp.stop_time = nil
      @sdp.valid?.should be_false
    end

    it "is NOT valid when media_sections is empty" do
      @sdp[:media_sections] = []
      @sdp.valid?.should be_false
    end
  end

  context "bad initialize values" do
    it "ensures a Hash is passed in" do
      lambda do
        SDP::Description.new 1
      end.should raise_error SDP::RuntimeError
    end

    it "handles a Hash with irrelvant keys" do
      session_values = { :bobo => "thing" }

      lambda do
        SDP::Description.new session_values
      end.should raise_error SDP::RuntimeError
    end
  end
end