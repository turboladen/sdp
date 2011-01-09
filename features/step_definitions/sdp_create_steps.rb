require 'sdp/description'

Given /^I know what the SDP file should look like$/ do
  @example_sdp_file = File.open(File.dirname(__FILE__) + "/../support/sdp_file.txt", 'r')
end

When /^I build the Ruby object with the appropriate fields$/ do
  @sdp = SDP::Description.new
  @sdp.protocol_version = 0
  @sdp.username = "jdoe"
  @sdp.session_id = 2890844526
  @sdp.session_version = 2890842807
  @sdp.network_type = :IN
  @sdp.address_type = :IP4
  @sdp.unicast_address = "10.47.16.5"
  @sdp.session_name = "SDP Seminar"
  @sdp.session_information = "A Seminar on the session description protocol"
  @sdp.uri = "http://www.example.com/seminars/sdp.pdf"
  @sdp.email_address = "j.doe@example.com (Jane Doe)"
=begin
  @sdp.add_field(:connection_data, {
    :net_type           => "IN",
    :address_type       => "IP4",
    :connection_address => "224.2.17.12/127"
  } )
  @sdp.add_field(:timing, {
    :start_time => 2873397496,
    :stop_time => 2873404696
  } )
  @sdp.add_field(:attribute, { :attribute => "recvonly" })
  @sdp.add_field(:media_description, {
    :media => "audio",
    :port => 49170,
    :protocol => "RTP/AVP",
    :format => "0"
  })
  @sdp.add_field(:media_description, {
    :media => "video",
    :port => 51372,
    :protocol => "RTP/AVP",
    :format => "99"
  })
  #@sdp.media_description = { :media => "video", ... }
  #@sdp.media_description = { :media => "audio", ... }
  #@sdp.assoc   # => { :media => "video", ... }
  #@sdp.media_description[1].media   # => { :media => "video", ... }
  @sdp.add_field(:attribute, {
    :attribute => "rtpmap",
    :value => "99 h263-1998/90000"
  })
=end
end

Then /^the resulting file should look like the intended description$/ do
  @sdp.to_s.should == @example_sdp_file.read
end

Given /^I create an SDP object with no parameters$/ do
  @sdp = SDP::Description.new
end

When /^I convert it to a String$/ do
  @sdp_string = @sdp.to_s
end

Then /^it should have :version set to (\d+)$/ do |value|
  @sdp_string.should match /v=#{value}/
end

Then /^it should have all :origin fields set$/ do
  @sdp_string.should match(/o=\w+ \d+ \d+ IN IP4 \w+/)
end
