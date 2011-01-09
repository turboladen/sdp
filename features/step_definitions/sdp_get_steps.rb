Given /^the RFC 4566 SDP example in a file$/ do
  @sdp_file = File.open(File.dirname(__FILE__) + '/../support/sdp_file.txt', 'r').read
end

When /^I parse the file$/ do
  @sdp = SDP.parse @sdp_file
  require 'ap'
  ap @sdp
end

Then /^the <value> for <field> is accessible via the SDP object$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |sdp_field|
    puts sdp_field

    type = sdp_field["field"].to_sym
    value = sdp_field["value"]

puts type
    if sdp_field["parameter"].empty?
      @sdp[type].should == value
    else
      sub_type = sdp_field["parameter"].to_sym
      pp @sdp[type]
      pp @sdp[:origin]
      @sdp.fetch(type).fetch(sub_type).should == value
    end
  end
end
