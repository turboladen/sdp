require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/time_zones_field'

describe SDP::DescriptionFields::TimeZonesField do
  context "#initialize" do
    before do
      @time_zones_field = SDP::DescriptionFields::TimeZonesField.new
    end

    it "sets :sdp_type set to 'z'" do
      @time_zones_field.sdp_type.should == 'z'
    end

    it "sets :ruby_type set to :time_zones" do
      @time_zones_field.ruby_type.should == :time_zones
    end

    it "sets :required set to true" do
      @time_zones_field.required.should be_false
    end

    it "sets :value[:adjustment_time] set to ''" do
      @time_zones_field.value[:adjustment_time].should == ''
    end

    it "sets :value[:offset] set to ''" do
      @time_zones_field.value[:offset].should == ''
    end

    it "is NOT valid" do
      @time_zones_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @time_zones_field = SDP::DescriptionFields::TimeZonesField.new
    end

    it "can accept a new value of :adjustment_time => 12345" do
      offset = @time_zones_field.value[:offset]
      @time_zones_field.value = { :adjustment_time => 12345 }
      @time_zones_field.value[:adjustment_time].should == 12345
      @time_zones_field.value[:offset].should == offset
    end

    it "can accept a new value of :offset => 678" do
      adjustment_time = @time_zones_field.value[:adjustment_time]
      @time_zones_field.value = { :offset => 678 }
      @time_zones_field.value[:offset].should == 678
      @time_zones_field.value[:adjustment_time].should == adjustment_time
    end

    it "can accept new value of :adjustment_time => 12345, :offset => 678" do
      @time_zones_field.value = { :adjustment_time => 12345, :offset => 678 }
      @time_zones_field.value[:adjustment_time].should == 12345
      @time_zones_field.value[:offset].should == 678
    end

    it "outputs a string of 'z=12345 678" do
      @time_zones_field.value = { :adjustment_time => 12345, :offset => 678 }
      @time_zones_field.to_sdp_s.should == "z=12345 678\r\n"
    end

    it "is valid after setting values" do
      @time_zones_field.value = { :adjustment_time => 12345, :offset => 678 }
      @time_zones_field.valid?.should be_true
    end

    it "is NOT valid when :adjustment_time is empty" do
      @time_zones_field.value = { :adjustment_time => '', :offset => 678 }
      @time_zones_field.valid?.should be_false
    end

    it "is NOT valid when :offset is empty" do
      @time_zones_field.value = { :adjustment_time => 12345, :offset => '' }
      @time_zones_field.valid?.should be_false
    end
  end
end