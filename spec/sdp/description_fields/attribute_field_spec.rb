require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/attribute_field'

describe SDP::DescriptionFields::AttributeField do
  context "#initialize" do
    before do
      @attribute_field = SDP::DescriptionFields::AttributeField.new
    end

    it "sets :sdp_type to 'a'" do
      @attribute_field.sdp_type.should == 'a'
    end

    it "sets :ruby_type to :attribute" do
      @attribute_field.ruby_type.should == :attribute
    end

    it "sets :required to false" do
      @attribute_field.required.should be_false
    end

    it "sets :value[:attribute] to ''" do
      @attribute_field.value[:attribute].should == ''
    end

    it "sets :value[:value] to ''" do
      @attribute_field.value[:value].should == ''
    end

    it "is NOT valid" do
      @attribute_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @attribute_field = SDP::DescriptionFields::AttributeField.new
    end

    context "values" do
      it "can accept a new value of :attribute => 'rtpmap'" do
        validate_settings @attribute_field, :attribute => "rtpmap"
      end

      it "can accept a new value of :value => 99" do
        validate_settings @attribute_field, :value => 99
      end

      it "can accept new values of :attribute => 'clear', :value => 'blah'" do
        new_values = { :attribute => 'clear',
          :value => 'blah' }
        @attribute_field.value = new_values
        @attribute_field.value.should == new_values
      end
    end

    it "outputs a string of 'a=rtpmap:99 h263-1998/90000'" do
      @attribute_field.value = { :attribute => "rtpmap",
        :value => '99 h263-1998/90000' }
      @attribute_field.to_sdp_s.should == "a=rtpmap:99 h263-1998/90000\r\n"
    end

    it "is valid after setting values" do
      @attribute_field.value = { :attribute => "base64",
        :value => 'lotsofnumbersandstuff' }
      @attribute_field.valid?.should be_true
    end

    it "is NOT valid when :attribute is empty" do
      @attribute_field.value = { :attribute => '',
        :value => "stuff" }
      @attribute_field.valid?.should be_false
    end

    it "is valid when :value is empty" do
      @attribute_field.value = { :attribute => 'recvonly',
        :value => "" }
      @attribute_field.valid?.should be_true
    end
  end
end
