require 'spec_helper'
require 'sdp/field_dsl'


describe SDP::FieldDSL do
  subject do
    Class.new do
      include SDP::FieldDSL
    end
  end

  describe "#settings" do
    it "allows access to all DSLMethods as instance methods" do
      field = subject.new
      field.settings.should respond_to :field_value
      field.settings.should respond_to :field_values
      field.settings.should respond_to :optional_field_values
      field.settings.should respond_to :prefix
      field.settings.should respond_to :allow_multiple
      field.settings.should respond_to :allows_multiple?
    end
  end

  describe ".field_value" do
    it "must be a Symbol" do
      expect { subject.field_value("pants") }.to raise_error
      expect { subject.field_value(:pants) }.to_not raise_error
    end

    it "adds the value to the list of field values" do
      subject.field_value(:pants)
      subject.instance_variable_get(:@field_values).should == [:pants]
    end

    it "defines getter & setter instance methods by the value's name" do
      subject.field_value(:pants)
      subject.new.should respond_to :pants
      subject.new.should respond_to :pants=
    end

    context "optional is true" do
      it "adds the value to the list of optional field values" do
        subject.field_value(:pants, true)
        subject.instance_variable_get(:@optional_field_values).should == [:pants]
      end
    end
  end

  describe ".field_values" do
    it "allows access to @field_values" do
      subject.field_values.should == subject.instance_variable_get(:@field_values)
    end
  end

  describe ".optional_field_values" do
    it "allows access to @optional_field_values" do
      subject.optional_field_values.should ==
        subject.instance_variable_get(:@optional_field_values)
    end
  end

  describe ".prefix" do
    it "doesn't allow itself to be changed once it's been set" do
      subject.prefix(:x)
      expect { subject.prefix(:y) }.to raise_error
    end

    context "no param given" do
      it "returns the value set for @prefix" do
        subject.instance_variable_set(:@prefix, :x)
        subject.prefix.should == :x
      end
    end

    context "param given" do
      it "stores the param" do
        subject.prefix(:x)
        subject.prefix.should == :x
      end
    end
  end

  describe ".allows_multiple?" do
    context ".allow_multiple has been called" do
      it "is true" do
        subject.allow_multiple
        subject.allows_multiple?.should be_true
      end
    end

    context ".allow_multiple has not been called" do
      it "is true" do
        subject.allows_multiple?.should be_false
      end
    end
  end
end
