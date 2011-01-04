require File.dirname(__FILE__) + '/../spec_helper'
require 'sdp/description'

describe SDP::Description do
  before :each do
    @sdp = SDP::Description.new
  end

  it "initializes with no values set" do
    @sdp.should == []
  end

  context "can add and retrieve fields" do
    it ":attribute" do
      new_values = { :attribute => 'rtpmap',
        :value => "99 h263-1998/90000" }
      @sdp.add_field(:attribute, new_values)
      @sdp[:attribute].should == new_values
    end

    it ":bandwidth" do
      new_values = { :bandwidth_type => :CT,
        :bandwidth => 100 }
      @sdp.add_field(:bandwidth, new_values)
      @sdp[:bandwidth].should == new_values
    end

    it ":connection_data" do
      new_values = { :net_type => :IN,
        :address_type => :IP4,
        :connection_address => 'localhost' }
      @sdp.add_field(:connection_data, new_values)
      @sdp[:connection_data].should == new_values
    end

    it ":email_address" do
      @sdp.add_field(:email_address, 'me@me.com')
      @sdp[:email_address].should == 'me@me.com'
    end
  
    it ":encryption_keys" do
      new_values = { :method => 'clear',
        :encryption_key => 'password' }
      @sdp.add_field(:encryption_keys, new_values)
      @sdp[:encryption_keys].should == new_values
    end
  
    it ":media_description" do
      new_values = { :media => 'audio',
        :port => 12345,
        :protocol => 'RTP/AVP',
        :format => 99 }
      @sdp.add_field(:media_description, new_values)
      @sdp[:media_description].should == new_values
    end

    it ":origin" do
      new_values = {
        :username         => "jdoe",
        :session_id       => 2890844526,
        :session_version  => 2890842807,
        :net_type         => "IN",
        :address_type     => :IP4,
        :unicast_address  => "10.47.16.5"
      }

      @sdp.add_field(:origin, new_values)
      @sdp[:origin].should == new_values
    end

    it ":phone_number" do
      @sdp.add_field(:phone_number, "+1 555 123 4567")
      @sdp[:phone_number].should == "+1 555 123 4567"
    end
  
    it ":repeat_times" do
      new_values = { :repeat_interval => 99112299,
        :active_duration => 12345,
        :offsets_from_start_time => 99 }
      @sdp.add_field(:repeat_times, new_values)
      @sdp[:repeat_times].should == new_values
    end

    it ":session_information" do
      @sdp.add_field(:session_information, "This is a session")
      @sdp[:session_information].should == "This is a session"
    end

    it ":session_name" do
      @sdp.add_field(:session_name, "This is a session")
      @sdp[:session_name].should == "This is a session"
    end
  
    it ":time_zones" do
      new_values = { :adjustment_time => 99112299,
        :offset => 99 }
      @sdp.add_field(:time_zones, new_values)
      @sdp[:time_zones].should == new_values
    end
  
    it ":timing" do
      new_values = { :start_time => 99112299,
        :stop_time => 999999999 }
      @sdp.add_field(:timing, new_values)
      @sdp[:timing].should == new_values
    end

    it ":uri" do
      @sdp.add_field(:uri, "http://localhost")
      @sdp[:uri].should == "http://localhost"
    end

    it ":version" do
      @sdp.add_field(:version, 0)
      @sdp[:version].should == 0
    end
  end

  context "can add and retrieve > 1 field of same type" do
    it ":attribute" do
      new_values = []
      new_values << { :attribute => 'recvonly',
        :value => "" }
      @sdp.add_field(:attribute, new_values[0])

      new_values << { :attribute => 'rtpmap',
        :value => '99 h263-1998/90000' }
      @sdp.add_field(:attribute, new_values[1])

      @sdp[:attribute].class.should == Array
      @sdp[:attribute][0].should == new_values[0]
      @sdp[:attribute][1].should == new_values[1]
    end

    it ":media_description" do
      new_values = []
      new_values << { :media => 'audio',
        :port => 12345,
        :protocol => 'RTP/AVP',
        :format => 99 }
      @sdp.add_field(:media_description, new_values[0])

      new_values << { :media => 'video',
        :port => 5678,
        :protocol => 'RTP/AVP',
        :format => 33 }
      @sdp.add_field(:media_description, new_values[1])

      @sdp[:media_description].class.should == Array
      @sdp[:media_description][0].should == new_values[0]
      @sdp[:media_description][1].should == new_values[1]
    end
  end
end