require 'spec_helper'
require 'sdp/description'


describe "Create descriptions" do
=begin
  let(:session) do
    session = SDP::Description.new
    session.protocol_version = 0
    session.username = "jdoe"
    session.id = 2890844526
    session.version = 2890842807
    session.network_type = :IN
    session.address_type = :IP4
    session.unicast_address = "10.47.16.5"
    session.name = "SDP Seminar"
    session.information = "A Seminar on the session description protocol"
    session.uri = "http://www.example.com/seminars/sdp.pdf"
    session.email_address = "j.doe@example.com (Jane Doe)"
    session.connection_network_type = "IN"
    session.connection_address_type = "IP4"
    session.connection_address = "224.2.17.12/127"
    session.start_time = 2873397496
    session.stop_time = 2873404696
    session.attributes << { :attribute => "recvonly" }
    session.media_sections <<
      { :media => "audio", :port => 49170, :protocol => "RTP/AVP", :format => 0 }
    session.media_sections <<
      { :media => "video", :port => 51372, :protocol => "RTP/AVP", :format => 99,
        :attributes => [{ :attribute => "rtpmap", :value => "99 h263-1998/90000" }]
      }

    session
  end

  it "can build programmatically" do
    example_file = File.read(File.dirname(__FILE__) + "/../support/sdp_file.txt")
    session.to_s.should == example_file
    session.should be_valid
  end
=end


  context "from scratch, adding fields in reverse order, no media sections" do
    it "from scratch" do
      d = SDP::Description.new
      d.add_group :session_section
      d.should_not be_valid

      expect {
        d.add_group :session_section
      }.to raise_error SDP::RuntimeError

      d.session_section.add_field :attribute
      d.session_section.attributes.last.attribute = 'tool'
      d.session_section.attributes.last.value = 'Test Tool v1'
      d.session_section.add_field :attribute
      d.session_section.add_field :attribute
      d.session_section.add_field :encryption_key
      d.session_section.add_field :time_zone_adjustments
      d.session_section.add_field :bandwidth
      d.session_section.add_field :bandwidth
      d.session_section.add_field :bandwidth
      d.session_section.add_field :connection_data
      d.session_section.add_field :phone_number
      d.session_section.add_field :email_address
      d.session_section.add_field :uri
      d.session_section.add_field :session_information
      d.session_section.add_field :session_name
      d.session_section.add_field :origin
      d.session_section.add_field :protocol_version

      d.session_section.add_group :time_description
      d.session_section.time_descriptions.last.add_field :repeat_times
      d.session_section.time_descriptions.last.add_field :timing

      d.should_not be_valid
      d.to_s.each_line { |l| p l }
=begin
      expect {
        d.session_description.add_field :origin
      }.to raise_error SDP::RuntimeError
      d.session_description.add_field :origin
      d.should_not be_valid

      expect {
        d.session_description.add_field :origin
      }.to raise_error SDP::RuntimeError

      d.session_description.add_field :protocol_version
      d.should_not be_valid

      expect {
        d.session_description.add_field :protocol_version
      }.to raise_error SDP::RuntimeError

      p d
=end
    end
  end
end
