=begin
require 'spec_helper'
require 'sdp/session_description'


describe SDP::SessionDescription do
  describe "#initialize" do
    it "creates read methods for all FIELDS" do
      SDP::SessionDescription::FIELDS.each do |field|
        subject.should respond_to field
      end
    end

    it "creates write methods for all FIELDS" do
      SDP::SessionDescription::FIELDS.each do |field|
        subject.should respond_to "#{field}="
      end
    end

    specify { subject.protocol_version.should be_zero }
  end

  describe "#seed" do
    it "sets some suggested values" do
      subject.seed

      subject.username.should_not be_empty
      subject.id.should be_a Fixnum
      subject.version.should == subject.id
      subject.network_type.should == "IN"
      subject.address_type.should == "IP4"
      subject.unicast_address.should_not be_empty
      subject.name.should == ' '
      subject.connection_network_type.should == "IN"
      subject.connection_address_type.should == "IP4"
      subject.connection_address.should == subject.send(:local_ip)
      subject.start_time.should == 0
      subject.stop_time.should == 0
    end
  end

  describe "#information=" do
    it "enforces UTF-8 encoding" do
      subject.information = "some info"
      subject.information.encoding.to_s.should == "UTF-8"
    end
  end

  describe "#has_connection_fields?" do
    context "connection fields in session section" do
      before do
        subject.connection_network_type = "IN"
        subject.connection_address_type = "IP4"
        subject.connection_address = "0.0.0.0"
      end

      specify do
        subject.has_connection_fields?.should be_true
      end
    end

    context "no connection fields in session section" do
      before do
        subject.connection_network_type = nil
        subject.connection_address_type = nil
        subject.connection_address = nil
      end

      specify do
        subject.has_connection_fields?.should be_false
      end
    end
  end

  describe "#valid?" do
    before do
      subject.protocol_version = 0
      subject.username = "jdoe"
      subject.id = 12345
      subject.version = 12345
      subject.network_type = :IN
      subject.address_type = :IP4
      subject.unicast_address = "127.0.0.1"
      subject.connection_network_type = :IN
      subject.connection_address_type = :IP4
      subject.connection_address = "127.0.0.1"
      subject.name = "This is a test"
      subject.start_time = 12345678
      subject.stop_time = 12345680
    end

    context "all required fields set" do
      specify { subject.should be_a_valid_description }
    end

    %w[protocol_version username id version network_type address_type
      unicast_address name start_time stop_time].each do |value|
      context "#{value} isn't set" do
        before { subject.send("#{value}=".to_sym, nil) }
        specify { subject.should_not be_a_valid_description }
      end
    end

    context "name is ' '" do
      before { subject.name = ' ' }
      specify { subject.should be_a_valid_description }
    end
  end

  describe "#local_ip" do
    specify { subject.send(:local_ip).should_not be_empty }
  end
end
=end
