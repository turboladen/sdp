Given /^the RFC 4566 SDP example in a file$/ do
  @sdp_file = File.open(File.dirname(__FILE__) + '/../support/sdp_file.txt', 'r').read
end

When /^I parse the file$/ do
  @sdp = SDP.parse @sdp_file
end

Then /^the <value> for <field> is accessible via the SDP object$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |sdp_field|
    field_type = sdp_field["field"].to_sym
    value = sdp_field["value"]

    actual_value = @sdp.send(field_type)

    if field_type == :attributes
      actual_value.first[:attribute].should == value
    else
      actual_value.to_s.should == value
    end
  end
end
