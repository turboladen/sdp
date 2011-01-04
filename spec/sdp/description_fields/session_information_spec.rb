require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/session_information_field'

describe SDP::DescriptionFields::SessionInformationField do
  context "#initialize" do
    before do
      @session_information_field = SDP::DescriptionFields::SessionInformationField.new
    end

    it "sets :sdp_type to 'i'" do
      @session_information_field.sdp_type.should == 'i'
    end

    it "sets :ruby_type to :session_information" do
      @session_information_field.ruby_type.should == :session_information
    end

    it "sets :required to false" do
      @session_information_field.required.should be_false
    end

    it "sets :value to ''" do
      @session_information_field.value.should == ''
    end

    it "is NOT valid" do
      @session_information_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @session_information_field = SDP::DescriptionFields::SessionInformationField.new
    end

    it "can accept a new value of 'This is a test'" do
      @session_information_field.value = 'This is a test'
      @session_information_field.value.should == 'This is a test'
    end

    it "outputs a string of 'i=This is a test" do
      @session_information_field.value = 'This is a test'
      @session_information_field.to_sdp_s.should == "i=This is a test\r\n"
    end

    it "is valid after changing the value" do
      @session_information_field.value = 'This is a test'
      @session_information_field.valid?.should be_true
    end
  end
end
