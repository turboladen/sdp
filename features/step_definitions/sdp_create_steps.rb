require 'sdp/description'

Given /^I know what the SDP file should look like$/ do
  @example_sdp_file = File.open(File.dirname(__FILE__) + "/../support/sdp_file.txt", 'r')
end

When /^I build the Ruby object with the appropriate fields$/ do
  @sdp = SDP::Description.new
  @sdp[:version] = 0
  @sdp[:origin].value[:username] = "jdoe"
  @sdp[:origin].value[:session_id] = 2890844526
  @sdp[:origin].value[:session_version] = 2890842807
  @sdp[:origin].value[:net_type] = "IN"
  @sdp[:origin].value[:address_type] = :IP4
  @sdp[:origin].value[:unicast_address] = "10.47.16.5"
  @sdp[:session_name] = "SDP Seminar"
  @sdp[:session_information] = "A Seminar on the session description protocol"
  @sdp[:uri] = "http://www.example.com/seminars/sdp.pdf"
  @sdp[:email_address] = "j.doe@example.com (Jane Doe)"
  @sdp[:connection_data].value[:net_type] = "IN"
  @sdp[:connection_data].value[:address_type] = "IP4"
  @sdp[:connection_data].value[:connection_address] = "224.2.17.12/127"
end

Then /^the resulting file should look like the intended description$/ do
  puts @sdp.to_s
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
