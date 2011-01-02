require 'sdp'

Given /^I know what the SDP file should look like$/ do
  pending
  @example_sdp_file = File.open(File.dirname(__FILE__) + "/../support/sdp_file.txt", 'r')
end

When /^I build the Ruby object with the appropriate fields$/ do
  pending
  @sdp = SDP.new
  @sdp.add_field :version => 0
end

Then /^the resulting file should look like the intended description$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I create an SDP object with no parameters$/ do
  @sdp = SDP.new
end

When /^I convert it to a String$/ do
  @sdp_string = @sdp.to_s
end

Then /^it should look like what's in the file "([^"]*)"$/ do |sdp_file|
  model_sdp = File.open(File.dirname(__FILE__) + "/../support/basic_sdp.txt", 'r')
  @sdp_string.should == model_sdp.read
end
