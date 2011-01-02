Given /^I know what the SDP file should look like$/ do
  @example_sdp_file = File.open(File.dirname(__FILE__) + "/../support/sdp_file.txt", 'r')
end

When /^I build the Ruby object with the appropriate fields$/ do
  @sdp = SDP.new
  @sdp.add_field :version => 0
  #@sdp.add_field :origin => { :username => "jdoe" }
  # custom: @sdp.add_field(:thing => "some value", :type_character => 'h')
end

Then /^the resulting file should look like the intended description$/ do
  pending # express the regexp above with the code you wish you had
end
