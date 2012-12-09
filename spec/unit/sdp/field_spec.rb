require 'spec_helper'
require 'sdp/field'


describe SDP::Field do
  describe ".new_from_type" do
    context "valid sdp_type" do
      it "returns a new SDP::Field object of that type" do
        SDP::Field.new_from_type(:attribute).should be_a SDP::Fields::Attribute
      end
    end

    context "invalid sdp_type" do
      it "raises a TypeError" do
        expect {
          SDP::Field.new_from_type(:pants)
        }.to raise_error TypeError
      end
    end
  end

  describe ".new_from_string" do
    context "string begins with valid Field prefix" do
      it "returns a new SDP::Field object of that type" do
        SDP::Field.new_from_string("v=0").should be_a SDP::Fields::ProtocolVersion
      end
    end

    context "string doesn't start with valid Field prefix" do
      it "raises" do
        expect {
          SDP::Field.new_from_string("xxxxxxxxx")
        }.to raise_error TypeError
      end
    end
  end

  describe ".new_from_hash" do
    context "hash key is a valid sdp_type" do
      let(:hash) { { protocol_version: { protocol_version: 0 } } }

      it "returns a new SDP::Field object of that type with the values set" do
        field = SDP::Field.new_from_hash(hash)
        field.should be_a SDP::Fields::ProtocolVersion
        field.protocol_version.should == 0
      end
    end

    context "hash key is not a valid sdp_type" do
      let(:hash) { { pants: "party" } }

      it "raises a TypeError" do
        expect {
          SDP::Field.new_from_hash(hash)
        }.to raise_error TypeError
      end
    end

    context "hash contains more than one key" do
      let(:hash) do
        { protocol_version: { protocol_version: 0 }, uri: { uri: "http://hi.com" } }
      end

      it "warns that only the first key/value pair will be used" do
        SDP::Field.should_receive(:warn)
        SDP::Field.new_from_hash(hash)
      end
    end
  end

  describe "#initialize" do
    context "passed in a Hash" do
      it "calls #add_from_hash with the param" do
        the_hash = {}
        SDP::Field.any_instance.should_receive(:add_from_hash).with(the_hash)
        SDP::Field.new(the_hash)
      end
    end

    context "passed in a String" do
      it "calls #add_from_string with the param" do
        the_string = ""
        SDP::Field.any_instance.should_receive(:add_from_string).with(the_string)
        SDP::Field.new(the_string)
      end
    end
  end

  describe "#add_from_string" do
    it "warns that the child should implement" do
      subject.should_receive(:warn)
      subject.add_from_string('some data')
    end
  end

  describe "#add_from_hash" do
    it "sets an instance variable by the name of the key with the value" do
      hash = { pants: "party", dance: "party" }
      subject.add_from_hash(hash)
      subject.instance_variable_get(:@pants).should == "party"
      subject.instance_variable_get(:@dance).should == "party"
    end
  end

  describe "#to_s" do
    before { subject.stub(:valid?).and_return true }

    context "settings.prefix is nil" do
      before { subject.stub_chain(:settings, :prefix).and_return nil }

      it "warns that the prefix isn't set" do
        subject.should_receive :warn
        subject.to_s
      end
    end

    context "settings.prefix is set" do
      before { subject.stub_chain(:settings, :prefix).and_return :x }

      it "doesn't warn about anything" do
        subject.should_not_receive :warn
        subject.to_s
      end
    end
  end

  describe "#to_hash" do
    it "converts field_values to key/value pairs with sdp_type as parent key" do
      subject.instance_variable_set(:@pants, "party")
      subject.instance_variable_set(:@dance, "party")
      subject.stub(:field_values).and_return [:pants, :dance]
      subject.to_hash.should == { field: { pants: "party", dance: "party" } }
    end
  end

  describe "#set_values" do
    it "gets all instance vars that are settings.field_values and that have a value" do
      subject.instance_variable_set(:@pants, "party")
      subject.instance_variable_set(:@dance, "party2")
      subject.instance_variable_set(:@rat, nil)
      subject.stub_chain(:settings, :field_values).and_return [:pants, :dance]
      subject.set_values.should == [:pants, :dance]
    end
  end

  describe "#required_values" do
    it "returns a list of field values that are not optional" do
      subject.stub_chain(:settings, :field_values).and_return [:one, :two]
      subject.stub_chain(:settings, :optional_field_values).and_return [:two]
      subject.required_values.should == [:one]
    end
  end

  describe "#errors" do
    it "returns all required values that aren't set" do
      subject.stub(:required_values).and_return [:one, :two]
      subject.stub(:set_values).and_return [:one]
      subject.errors.should == [:two]
    end
  end
end
