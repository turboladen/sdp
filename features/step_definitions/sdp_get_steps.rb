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
    @sdp[:sdp_field["field"]
  end
end

require 'strscan'
def field_to_hash_key field
  #string = StringScanner.new(field)
  words = field.scan(/\w+/)
    
end
