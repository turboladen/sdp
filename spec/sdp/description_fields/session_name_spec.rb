require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/session_name_field'

describe SDP::DescriptionFields::SessionNameField do
  context "#initialize" do
    before do
      @session_name_field = SDP::DescriptionFields::SessionNameField.new
    end

    it "sets :sdp_type to 's'" do
      @session_name_field.sdp_type.should == 's'
    end

    it "sets :ruby_type to :session_name" do
      @session_name_field.ruby_type.should == :session_name
    end

    it "sets :required to true" do
      @session_name_field.required.should be_true
    end

    it "sets :value to ' '" do
      @session_name_field.value.should == ' '
    end

    it "is valid" do
      @session_name_field.valid?.should be_true
    end
  end

  context "working with the object" do
    before :each do
      @session_name_field = SDP::DescriptionFields::SessionNameField.new
    end

    it "can accept a new value of 'This is a test'" do
      @session_name_field.value = 'This is a test'
      @session_name_field.value.should == 'This is a test'
    end

    it "outputs a string of 's=This is a test" do
      @session_name_field.value = 'This is a test'
      @session_name_field.to_sdp_s.should == "s=This is a test\r\n"
    end

    it "is valid after changing the value" do
      @session_name_field.value = 'This is a test'
      @session_name_field.valid?.should be_true
    end
  end
end
