require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/connection_data_field'

describe SDP::DescriptionFields::ConnectionDataField do
  context "#initialize" do
    before do
      @connection_data_field = SDP::DescriptionFields::ConnectionDataField.new
    end

    it "sets :sdp_type to 'c'" do
      @connection_data_field.sdp_type.should == 'c'
    end

    it "sets :ruby_type to :connection_data" do
      @connection_data_field.ruby_type.should == :connection_data
    end

    it "sets :required to false" do
      @connection_data_field.required.should be_false
    end

    it "sets :value[:net_type] to :IN" do
      @connection_data_field.value[:net_type].should == :IN
    end

    it "sets :value[:address_type] to :IP4" do
      @connection_data_field.value[:address_type].should == :IP4
    end

    it "sets :value[:connection_address] to the current IP address" do
      @connection_data_field.value[:connection_address].should == 
        @connection_data_field.get_local_ip
    end

    it "is valid" do
      @connection_data_field.valid?.should be_true
    end
  end

  context "working with the object" do
    before :each do
      @connection_data_field = SDP::DescriptionFields::ConnectionDataField.new
    end

    context "values" do
      it "can accept a new value of :net_type => :OUT" do
        validate_settings @connection_data_field, :net_type => :OUT
      end

      it "can accept a new value of :address_type => :IP6" do
        validate_settings @connection_data_field, :address_type => :IP6
      end

      it "can accept a new value of :connection_address => '127.0.0.1'" do
        validate_settings @connection_data_field, :connection_address => '127.0.0.1'
      end

      it "can accept new value of :BLAH, :IP999, '192.168.12.34'" do
        new_values = { :net_type => :OUT,
          :address_type => :IP6,
          :connection_address => '192.168.12.34' }
        @connection_data_field.value = new_values
        @connection_data_field.value.should == new_values
      end

      it "can accept new value of :net_type => :BOBO, :address_type => :IP12" do
        new_values = { :net_type => :BOBO,
          :address_type => :IP12 }
        validate_settings @connection_data_field, new_values
      end
    end

    it "outputs a string of 'c=IN IP6 127.0.0.2'" do
      @connection_data_field.value = { :net_type => :IN,
        :address_type => :IP6,
        :connection_address => '127.0.0.2' }
      @connection_data_field.to_sdp_s.should == "c=IN IP6 127.0.0.2\r\n"
    end

    it "is valid after setting values" do
      @connection_data_field.value = { :net_type => :IN,
        :address_type => :IP6,
        :connection_address => 'localhost' }
      @connection_data_field.valid?.should be_true
    end

    it "is NOT valid when :net_type is empty" do
      @connection_data_field.value = { :net_type => '',
        :address_type => :IP4,
        :connection_address => 'localhost' }
      @connection_data_field.valid?.should be_false
    end

    it "is NOT valid when :address_type is empty" do
      @connection_data_field.value = { :net_type => :IP,
        :address_type => "",
        :connection_address => 'localhost' }
      @connection_data_field.valid?.should be_false
    end

    it "is NOT valid when :protocol is empty" do
      @connection_data_field.value = { :net_type => :IP,
        :address_type => :IN,
        :connection_address => '' }
      @connection_data_field.valid?.should be_false
    end
  end
end
