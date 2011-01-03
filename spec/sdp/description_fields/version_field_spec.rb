require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/version_field'

describe SDP::DescriptionFields::VersionField do
  context "#initialize" do
    before do
      @version_field = SDP::DescriptionFields::VersionField.new
    end

    it "sets :sdp_type set to 'v'" do
      @version_field.sdp_type.should == 'v'
    end

    it "sets :ruby_type set to :version" do
      @version_field.ruby_type.should == :version
    end

    it "sets :required set to true" do
      @version_field.required.should be_true
    end

    it "sets :value set to SDP::SDP_VERSION" do
      @version_field.value.should == SDP::SDP_VERSION
    end
  end

  context "working with the object" do
    before :each do
      @version_field = SDP::DescriptionFields::VersionField.new
    end

    it "can accept a new value of 1" do
      @version_field.value = 1
      @version_field.value.should == 1
    end

    it "outputs a string of 'v=1" do
      @version_field.value = 1
      @version_field.to_sdp_s.should == "v=1\r\n"
    end

    it "is valid" do
      @version_field.valid?.should be_true
    end
  end
end