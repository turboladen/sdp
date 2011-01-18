require 'sdp/description'

Given /^I know what the SDP file should look like$/ do
  @example_sdp_file = File.read(File.dirname(__FILE__) + "/../support/sdp_file.txt")
end

When /^I build the Ruby object with the appropriate fields$/ do
  @session = SDP::Description.new
  @session.protocol_version = 0
  @session.username = "jdoe"
  @session.id = 2890844526
  @session.version = 2890842807
  @session.network_type = :IN
  @session.address_type = :IP4
  @session.unicast_address = "10.47.16.5"
  @session.name = "SDP Seminar"
  @session.information = "A Seminar on the session description protocol"
  @session.uri = "http://www.example.com/seminars/sdp.pdf"
  @session.email_address = "j.doe@example.com (Jane Doe)"
  @session.connection_address = "224.2.17.12/127"
  @session.start_time = 2873397496
  @session.stop_time = 2873404696
  @session.attributes << { :attribute => "recvonly" }
  @session.media_sections << 
    { :media => "audio", :port => 49170, :protocol => "RTP/AVP", :format => 0 }
  @session.media_sections << 
    { :media => "video", :port => 51372, :protocol => "RTP/AVP", :format => 99,
      :attributes => [{ :attribute => "rtpmap", :value => "99 h263-1998/90000" }]
    }
end

Then /^the resulting file should look like the intended description$/ do
  @session.to_s.should == @example_sdp_file
end

Given /^I create an SDP object with no parameters$/ do
  @session = SDP::Description.new
end

When /^I convert it to a String$/ do
  @sdp_string = @session.to_s
end

Then /^it should have :version set to (\d+)$/ do |value|
  @sdp_string.should match /v=#{value}/
end
