require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/uri_field'

describe SDP::DescriptionFields::UriField do
  context "#initialize" do
    before do
      @uri_field = SDP::DescriptionFields::UriField.new
    end

    it "sets :sdp_type set to 'u'" do
      @uri_field.sdp_type.should == 'u'
    end

    it "sets :ruby_type set to :uri" do
      @uri_field.ruby_type.should == :uri
    end

    it "sets :required set to false" do
      @uri_field.required.should be_false
    end

    it "sets :value set to ''" do
      @uri_field.value.should == ''
    end

    it "is NOT valid" do
      @uri_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @uri_field = SDP::DescriptionFields::UriField.new
    end

    it "can accept a new value of 'http://localhost'" do
      @uri_field.value = "http://localhost"
      @uri_field.value.to_s.should == "http://localhost"
    end

    it "outputs a string of 'u=http://localhost" do
      @uri_field.value = "http://localhost"
      @uri_field.to_sdp_s.should == "u=http://localhost\r\n"
    end

    it "is valid" do
      @uri_field.value = "http://localhost"
      @uri_field.valid?.should be_true
    end
  end
end