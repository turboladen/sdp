require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/bandwidth_field'

describe SDP::DescriptionFields::BandwidthField do
  context "#initialize" do
    before do
      @bandwidth_field = SDP::DescriptionFields::BandwidthField.new
    end

    it "sets :sdp_type to 'b'" do
      @bandwidth_field.sdp_type.should == 'b'
    end

    it "sets :ruby_type to :bandwidth" do
      @bandwidth_field.ruby_type.should == :bandwidth
    end

    it "sets :required to false" do
      @bandwidth_field.required.should be_false
    end

    it "sets :value[:bandwidth_type] to ''" do
      @bandwidth_field.value[:bandwidth_type].should == ''
    end

    it "sets :value[:bandwidth] to ''" do
      @bandwidth_field.value[:bandwidth].should == ''
    end

    it "is NOT valid" do
      @bandwidth_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @bandwidth_field = SDP::DescriptionFields::BandwidthField.new
    end

    context "values" do
      it "can accept a new value of :bandwidth_type => :CT" do
        validate_settings @bandwidth_field, :bandwidth_type => :CT
      end

      it "can accept a new value of :bandwidth => 100" do
        validate_settings @bandwidth_field, :bandwidth => 100
      end

      it "can accept new values of :bandwidth_type => :AS, :bandwidth => 10" do
        new_values = { :bandwidth_type => :AS,
          :bandwidth => 10 }
        @bandwidth_field.value = new_values
        @bandwidth_field.value.should == new_values
      end
    end

    it "outputs a string of 'b=CT:1000'" do
      @bandwidth_field.value = { :bandwidth_type => :CT,
        :bandwidth => 1000 }
      @bandwidth_field.to_sdp_s.should == "b=CT:1000\r\n"
    end

    it "is valid after setting values" do
      @bandwidth_field.value = { :bandwidth_type => :CT,
        :bandwidth => 1000 }
      @bandwidth_field.valid?.should be_true
    end

    it "is NOT valid when :bandwidth_type is empty" do
      @bandwidth_field.value = { :bandwidth_type => '',
        :bandwidth => 1000 }
      @bandwidth_field.valid?.should be_false
    end

    it "is NOT valid when :bandwidth is empty" do
      @bandwidth_field.value = { :bandwidth_type => :CT,
        :bandwidth => '' }
      @bandwidth_field.valid?.should be_false
    end
  end
end
