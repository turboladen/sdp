=begin
require 'spec_helper'
require 'sdp'
require 'sdp/description'
require 'base64'

describe SDP::Description do
  describe "#initialize" do
    it "protocol_version value set" do
      subject.protocol_version.should == SDP::PROTOCOL_VERSION
    end
  end

  describe "getter/setter methods with basic values" do
    {
      :protocol_version => 1,
      :username => "jdoe",
      :id => 2890844526,
      :version => 2890842807,
      :network_type => :IN,
      :address_type => :IP4,
      :unicast_address => "10.47.16.5",
      :name => "This is a session",
      :information => "This is a session",
      :uri => "http://localhost",
      :email_address => "me@me.com",
      :phone_number => "+1 555 123 4567",
      :connection_network_type => "IN",
      :connection_address_type => "IP4",
      :connection_address => 'localhost',
      :bandwidth_type => :CT,
      :bandwidth => 100,
      :start_time => 99112299,
      :stop_time => 99999999,
      :repeat_interval => 12345,
      :active_duration => 12345,
      :offsets_from_start_time => 99,
    }.each do |k, v|
      describe "##{k}=" do
        specify {
          subject.send("#{k}=".to_sym, v)
          subject.send("#{k}".to_sym).should == v
        }
      end
    end
  end

  describe "#name=" do
    it "can be a ' '" do
      subject.name = " "
      subject.name.should == " "
    end
  end

  describe "#email_address" do
    it "in alternate form" do
      subject.email_address = "Jane Doe <j.doe@example.com>"
      subject.email_address.should == "Jane Doe <j.doe@example.com>"
    end
  end

  describe "#connection_address=" do
    context "using TTL" do
      specify {
        subject.connection_address = "224.2.36.42/127"
        subject.connection_address.should == "224.2.36.42/127"
      }
    end

    context "using IPv6 address and count" do
      specify {
        subject.connection_address = "FF15::101/3"
        subject.connection_address.should == "FF15::101/3"
      }
    end
  end

  describe "#time_zones" do
    it "one time zone" do
      new_values = { :adjustment_time => 111111,
        :offset => 99 }
      subject.time_zones << new_values
      subject.time_zones.should == [new_values]
    end

    it "two time_zones" do
      new_values1 = { :adjustment_time => 111111,
        :offset => 99 }
      new_values2 = { :adjustment_time => 222222,
        :offset => 88 }
      subject.time_zones << new_values1
      subject.time_zones << new_values2
      subject.time_zones.should == [new_values1, new_values2]
    end
  end

  describe "#encryption_keys" do
    context "encryption_method = clear" do
      specify {
        subject.encryption_method = 'clear'
        subject.encryption_method.should == 'clear'
        subject.encryption_key = 'password'
        subject.encryption_key.should == 'password'
      }
    end

    context "encryption_method = base64" do
      specify {
        subject.encryption_method = 'base64'
        subject.encryption_method.should == 'base64'
        enc = Base64.encode64('password')
        subject.encryption_key = enc
        subject.encryption_key.should == enc
      }
    end

    context "encryption_method = uri" do
      specify {
        subject.encryption_method = 'uri'
        subject.encryption_method.should == 'uri'
        uri = "http://aserver.com/thing.pdf"
        subject.encryption_key = uri
        subject.encryption_key.should == uri
      }
    end

    context "encryption_method = prompt" do
      specify {
        subject.encryption_method = 'prompt'
        subject.encryption_method.should == 'prompt'
        subject.encryption_key.should be_nil
      }
    end
  end

  describe "#attributes" do
    context "one attribute with value" do
      specify {
        new_values = { :attribute => 'rtpmap',
          :value => "99 h263-1998/90000" }
        subject.attributes << new_values
        subject.attributes.first.should == new_values
      }
    end

    context "one attribute with empty value" do
      specify {
        new_values = { :attribute => 'rtpmap',
          :value => "" }
        subject.attributes << new_values
        subject.attributes.first.should == new_values
      }
    end

    context "one attribute with nil value" do
      specify {
        new_values = { :attribute => 'rtpmap' }
        subject.attributes << new_values
        subject.attributes.first.should == new_values
      }
    end

    context "two attributes" do
      specify {
        new_values1 = { :attribute => 'test' }
        new_values2 = { :attribute => 'rtpmap',
          :value => "99 h263-1998/90000" }
        subject.attributes << new_values1
        subject.attributes << new_values2
        subject.attributes.should == [new_values1, new_values2]
      }
    end
  end

  describe "#media_sections" do
    it "can add a basic media section" do
      new_values = { :media => 'audio',
        :port => 12345,
        :protocol => 'RTP/AVP',
        :format => 99 }
      subject.media_sections << new_values
      subject.media_sections.first.should == new_values
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
      subject.media_sections << new_values
      subject.media_sections.first.should == new_values
    end

    it "can add 2 basic media sections" do
      new_values = []
      new_values << { :media => 'audio',
        :port => 12345,
        :protocol => 'RTP/AVP',
        :format => 99 }
      subject.media_sections << new_values[0]

      new_values << { :media => 'video',
        :port => 5678,
        :protocol => 'RTP/AVP',
        :format => 33 }
      subject.media_sections << new_values[1]

      subject.media_sections.class.should == Array
      subject.media_sections[0].should == new_values[0]
      subject.media_sections[1].should == new_values[1]
    end
  end

  context "#to_s" do
    it "contains required session section values" do
      subject.to_s.should match /v=0/
      subject.to_s.should match /o=/
      subject.to_s.should match /s=/
      subject.to_s.should match /t=/
    end

    it "ends each line with \r\n" do
      subject.to_s.each_line do |l|
        l.should match /\r\n$/
      end
    end

    it "handles descriptions with no time zone" do
      sdp = SDP.parse(SDP_MISSING_TIME)
      expect { sdp.to_s }.to_not raise_error
    end
  end

  describe "#valid?" do
    before do
      subject.protocol_version = 0
      subject.username = "jdoe"
      subject.id = 12345
      subject.version = 12345
      subject.network_type = :IN
      subject.address_type = :IP4
      subject.unicast_address = "127.0.0.1"
      subject.connection_network_type = :IN
      subject.connection_address_type = :IP4
      subject.connection_address = "127.0.0.1"
      subject.name = "This is a test"
      subject.start_time = 12345678
      subject.stop_time = 12345680
    end

    context "all required fields set" do
      specify { subject.should be_a_valid_description }
    end

    %w[protocol_version username id version network_type address_type
      unicast_address name start_time stop_time].each do |value|
      context "#{value} isn't set" do
        before { subject.send("#{value}=".to_sym, nil) }
        specify { subject.should_not be_a_valid_description }
      end
    end

    context "name is ' '" do
      before { subject.name = ' ' }
      specify { subject.should be_a_valid_description }
    end

    context "media_sections is empty" do
      before { subject[:media_sections] = [] }
      specify { subject.should be_a_valid_description }
    end
  end


  context "bad initialize values" do
    it "ensures a Hash is passed in" do
      expect {
        SDP::Description.new 1
      }.to raise_error SDP::RuntimeError
    end

    it "handles a Hash with irrelvant keys" do
      session_values = { :bobo => "thing" }

      expect {
        SDP::Description.new session_values
      }.to raise_error SDP::RuntimeError
    end
  end
end
=end
