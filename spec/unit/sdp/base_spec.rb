require 'spec_helper'
require 'sdp/base'

describe SDP::Base do
  describe "#to_s" do
    context "is valid" do
      before { subject.stub(:valid?).and_return true }

      it "should not warn about errors" do
        subject.should_not_receive(:warn)
        subject.to_s
      end
    end

    context "is not valid" do
      before { subject.stub(:valid?).and_return false }

      it "should warn about errors" do
        subject.should_receive(:errors)
        subject.should_receive(:warn)
        subject.to_s
      end
    end
  end

  describe "#to_hash" do
    it "should warn that children should implement it" do
      subject.should_receive(:warn)
      subject.to_hash
    end
  end

  describe "#valid?" do
    it "checks if errors is empty" do
      errors = double "#errors"
      errors.should_receive(:empty?)
      subject.should_receive(:errors).and_return(errors)
      subject.valid?
    end
  end

  describe "#errors" do
    it "should warn that children should implement it" do
      subject.should_receive(:warn)
      subject.errors
    end
  end

  describe "#sdp_type" do
    specify { subject.sdp_type.should == :base }
  end

  describe "#seed" do
    it "should warn that children should implement it" do
      subject.should_receive(:warn)
      subject.seed
    end
  end
end
