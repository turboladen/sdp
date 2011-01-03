require 'sdp/description'

Given /^I know what the SDP file should look like$/ do
  @example_sdp_file = File.open(File.dirname(__FILE__) + "/../support/sdp_file.txt", 'r')
end

When /^I build the Ruby object with the appropriate fields$/ do
  @sdp = SDP::Description.new
  @sdp[:version] = 0
  @sdp[:origin][:username] = "jdoe"
end

Then /^the resulting file should look like the intended description$/ do
  pending # express the regexp above with the code you wish you had
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
