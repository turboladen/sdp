require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/phone_number_field'

describe SDP::DescriptionFields::PhoneNumberField do
  context "#initialize" do
    before do
      @phone_number_field = SDP::DescriptionFields::PhoneNumberField.new
    end

    it "sets :sdp_type set to 'p'" do
      @phone_number_field.sdp_type.should == 'p'
    end

    it "sets :ruby_type set to :phone_number" do
      @phone_number_field.ruby_type.should == :phone_number
    end

    it "sets :required set to false" do
      @phone_number_field.required.should be_false
    end

    it "sets :value set to ''" do
      @phone_number_field.value.should == ''
    end

    it "is NOT valid" do
      @phone_number_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @phone_number_field = SDP::DescriptionFields::PhoneNumberField.new
    end

    it "can accept a new value of 'This is a test'" do
      @phone_number_field.value = '+1 555 123 4567'
      @phone_number_field.value.should == '+1 555 123 4567'
    end

    it "outputs a string of 'p=+1 555 123 4567" do
      @phone_number_field.value = '+1 555 123 4567'
      @phone_number_field.to_sdp_s.should == "p=+1 555 123 4567\r\n"
    end

    it "is valid after changing the value" do
      @phone_number_field.value = '+1 555 123 4567'
      @phone_number_field.valid?.should be_true
    end
  end
end
