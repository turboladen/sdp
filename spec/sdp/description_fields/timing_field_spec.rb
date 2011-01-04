require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/timing_field'

describe SDP::DescriptionFields::TimingField do
  context "#initialize" do
    before do
      @timing_field = SDP::DescriptionFields::TimingField.new
    end

    it "sets :sdp_type to 't'" do
      @timing_field.sdp_type.should == 't'
    end

    it "sets :ruby_type to :timing" do
      @timing_field.ruby_type.should == :timing
    end

    it "sets :required to true" do
      @timing_field.required.should be_true
    end

    it "sets :value[:start_time] to a number" do
      @timing_field.value[:start_time].class.should == Fixnum
    end

    it "sets :value[:stop_time] to a number" do
      @timing_field.value[:stop_time].class.should == Fixnum
    end

    it "is NOT valid" do
      @timing_field.valid?.should be_true
    end
  end

  context "working with the object" do
    before :each do
      @timing_field = SDP::DescriptionFields::TimingField.new
    end

    it "can accept a new value of :start_time => 12345" do
      stop_time = @timing_field.value[:stop_time]
      @timing_field.value = { :start_time => 12345 }
      @timing_field.value[:start_time].should == 12345
      @timing_field.value[:stop_time].should == stop_time
    end

    it "can accept a new value of :stop_time => 12345" do
      start_time = @timing_field.value[:start_time]
      @timing_field.value = { :stop_time => 12345 }
      @timing_field.value[:stop_time].should == 12345
      @timing_field.value[:start_time].should == start_time
    end

    it "can accept new value of :start_time => 12345, :stop_time => 678" do
      @timing_field.value = { :start_time => 12345, :stop_time => 678 }
      @timing_field.value[:start_time].should == 12345
      @timing_field.value[:stop_time].should == 678
    end

    it "outputs a string of 't=12345 678" do
      @timing_field.value = { :start_time => 12345, :stop_time => 678 }
      @timing_field.to_sdp_s.should == "t=12345 678\r\n"
    end

    it "is valid" do
      @timing_field.value = { :start_time => 12345, :stop_time => 678 }
      @timing_field.valid?.should be_true
    end

    it "is NOT valid when :start_time is empty" do
      @timing_field.value = { :start_time => '', :stop_time => 678 }
      @timing_field.valid?.should be_false
    end

    it "is NOT valid when :stop_time is empty" do
      @timing_field.value = { :start_time => 12345, :stop_time => '' }
      @timing_field.valid?.should be_false
    end
  end
end