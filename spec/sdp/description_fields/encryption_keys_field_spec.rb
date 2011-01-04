require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/encryption_keys_field'

describe SDP::DescriptionFields::EncryptionKeysField do
  context "#initialize" do
    before do
      @encryption_keys_field = SDP::DescriptionFields::EncryptionKeysField.new
    end

    it "sets :sdp_type to 'k'" do
      @encryption_keys_field.sdp_type.should == 'k'
    end

    it "sets :ruby_type to :origin" do
      @encryption_keys_field.ruby_type.should == :encryption_keys
    end

    it "sets :required to false" do
      @encryption_keys_field.required.should be_false
    end

    it "sets :value[:method] to ''" do
      @encryption_keys_field.value[:method].should == ''
    end

    it "sets :value[:encryption_key] to ''" do
      @encryption_keys_field.value[:encryption_key].should == ''
    end

    it "is NOT valid" do
      @encryption_keys_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @encryption_keys_field = SDP::DescriptionFields::EncryptionKeysField.new
    end

    context "values" do
      it "can accept a new value of :method => 'base64'" do
        validate_settings @encryption_keys_field, :method => "base64"
      end

      it "can accept a new value of :encryption_key => 'password'" do
        validate_settings @encryption_keys_field, :encryption_key => 'password'
      end

      it "can accept new values of :method => 'clear', :encryption_key => 'blah'" do
        new_values = { :method => 'clear',
          :encryption_key => 'blah' }
        @encryption_keys_field.value = new_values
        @encryption_keys_field.value.should == new_values
      end
    end

    it "outputs a string of 'k=clear:thepassword'" do
      @encryption_keys_field.value = { :method => "clear",
        :encryption_key => 'thepassword' }
      @encryption_keys_field.to_sdp_s.should == "k=clear:thepassword\r\n"
    end

    it "is valid after setting values" do
      @encryption_keys_field.value = { :method => "base64",
        :encryption_key => 'lotsofnumbersandstuff' }
      @encryption_keys_field.valid?.should be_true
    end

    it "is NOT valid when :method is empty" do
      @encryption_keys_field.value = { :method => '',
        :encryption_key => "stuff" }
      @encryption_keys_field.valid?.should be_false
    end

    it "is valid when :encryption_key is empty" do
      @encryption_keys_field.value = { :method => 'prompt',
        :encryption_key => "" }
      @encryption_keys_field.valid?.should be_true
    end
  end
end
