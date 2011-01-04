require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/repeat_times_field'

describe SDP::DescriptionFields::RepeatTimesField do
  context "#initialize" do
    before do
      @repeat_times_field = SDP::DescriptionFields::RepeatTimesField.new
    end

    it "sets :sdp_type to 'r'" do
      @repeat_times_field.sdp_type.should == 'r'
    end

    it "sets :ruby_type to :time_zones" do
      @repeat_times_field.ruby_type.should == :repeat_times
    end

    it "sets :required to false" do
      @repeat_times_field.required.should be_false
    end

    it "sets :value[:repeat_interval] to ''" do
      @repeat_times_field.value[:repeat_interval].should == ''
    end

    it "sets :value[:active_duration] to ''" do
      @repeat_times_field.value[:active_duration].should == ''
    end

    it "sets :value[:offsets_from_start_time] to ''" do
      @repeat_times_field.value[:offsets_from_start_time].should == ''
    end

    it "is NOT valid" do
      @repeat_times_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @repeat_times_field = SDP::DescriptionFields::RepeatTimesField.new
    end

    it "can accept a new value of :repeat_interval => 12345" do
      active_duration = @repeat_times_field.value[:active_duration]
      offsets = @repeat_times_field.value[:offsets_from_start_time]
      @repeat_times_field.value = { :repeat_interval => 12345 }
      @repeat_times_field.value[:repeat_interval].should == 12345
      @repeat_times_field.value[:active_duration].should == active_duration
      @repeat_times_field.value[:offsets_from_start_time].should == offsets
    end

    it "can accept a new value of :active_duration => 678" do
      repeat_interval = @repeat_times_field.value[:repeat_interval]
      offsets = @repeat_times_field.value[:offsets_from_start_time]
      @repeat_times_field.value = { :active_duration => 678 }
      @repeat_times_field.value[:active_duration].should == 678
      @repeat_times_field.value[:repeat_interval].should == repeat_interval
      @repeat_times_field.value[:offsets_from_start_time].should == offsets
    end

    it "can accept a new value of :offsets_from_start_time => 9" do
      repeat_interval = @repeat_times_field.value[:repeat_interval]
      active_duration = @repeat_times_field.value[:active_duration]
      @repeat_times_field.value = { :offsets_from_start_time => 9 }
      @repeat_times_field.value[:offsets_from_start_time].should == 9
      @repeat_times_field.value[:repeat_interval].should == repeat_interval
      @repeat_times_field.value[:active_duration].should == active_duration
    end

    it "can accept new value of 12345, 678, and 9" do
      @repeat_times_field.value = { :repeat_interval => 12345,
        :active_duration => 678,
        :offsets_from_start_time => 9 }
      @repeat_times_field.value[:repeat_interval].should == 12345
      @repeat_times_field.value[:active_duration].should == 678
      @repeat_times_field.value[:offsets_from_start_time].should == 9
    end

    it "outputs a string of 'r=12345 678 9" do
      @repeat_times_field.value = { :repeat_interval => 12345,
        :active_duration => 678,
        :offsets_from_start_time => 9 }
      @repeat_times_field.to_sdp_s.should == "r=12345 678 9\r\n"
    end

    it "is valid after setting values" do
      @repeat_times_field.value = { :repeat_interval => 12345,
        :active_duration => 678,
        :offsets_from_start_time => 9 }
      @repeat_times_field.valid?.should be_true
    end

    it "is NOT valid when :repeat_interval is empty" do
      @repeat_times_field.value = { :repeat_interval => '',
        :active_duration => 678,
        :offsets_from_start_time => 9 }
      @repeat_times_field.valid?.should be_false
    end

    it "is NOT valid when :active_duration is empty" do
      @repeat_times_field.value = { :repeat_interval => 12345,
        :active_duration => '',
        :offsets_from_start_time => 9 }
      @repeat_times_field.valid?.should be_false
    end

    it "is NOT valid when :offsets_from_start_time is empty" do
      @repeat_times_field.value = { :repeat_interval => 12345,
        :active_duration => 678,
        :offsets_from_start_time => '' }
      @repeat_times_field.valid?.should be_false
    end
  end
end
