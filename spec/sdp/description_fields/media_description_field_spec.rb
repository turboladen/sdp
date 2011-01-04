require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/media_description_field'

describe SDP::DescriptionFields::MediaDescriptionField do
  context "#initialize" do
    before do
      @media_description_field = SDP::DescriptionFields::MediaDescriptionField.new
    end

    it "sets :sdp_type to 'm'" do
      @media_description_field.sdp_type.should == 'm'
    end

    it "sets :ruby_type to :media_description" do
      @media_description_field.ruby_type.should == :media_description
    end

    it "sets :required to true" do
      @media_description_field.required.should be_true
    end

    it "sets :value[:media] to ''" do
      @media_description_field.value[:media].should == ""
    end

    it "sets :value[:port] to ''" do
      @media_description_field.value[:port].should == ""
    end

    it "sets :value[:protocol] to ''" do
      @media_description_field.value[:protocol].should == ""
    end

    it "sets :value[:format] to ''" do
      @media_description_field.value[:format].should == ""
    end

    it "is NOT valid" do
      @media_description_field.valid?.should be_false
    end
  end

  context "working with the object" do
    before :each do
      @media_description_field = SDP::DescriptionFields::MediaDescriptionField.new
    end

    context "values" do
      it "can accept a new value of :media => 'audio'" do
        validate_settings @media_description_field, :media => "audio"
      end

      it "can accept a new value of :port => 1234" do
        validate_settings @media_description_field, :port => 1234
      end

      it "can accept a new value of :protocol => 'RTP/AVP" do
        validate_settings @media_description_field, :protocol => 'RTP/AVP'
      end

      it "can accept a new value of :format => 31" do
        validate_settings @media_description_field, :format => 31
      end

      it "can accept new value of 'video', 9999, 'RTP/SAVP', 99" do
        new_values = { :media => 'video',
          :port => 9999,
          :protocol => 'RTP/SAVP',
          :format => 99 }
        @media_description_field.value = new_values
        @media_description_field.value.should == new_values
      end

      it "can accept new value of :port => 9999, :format => 99" do
        new_values = { :port => 9999,
          :format => 99 }
        validate_settings @media_description_field, new_values
      end
    end

    it "outputs a string of 'm=audio 12345 udp 9999'" do
      @media_description_field.value = { :media => "audio",
        :port => 12345,
        :protocol => 'udp',
        :format => 9999 }
      @media_description_field.to_sdp_s.should == "m=audio 12345 udp 9999\r\n"
    end

    it "is valid after setting values" do
      @media_description_field.value = { :media => "audio",
        :port => 12345,
        :protocol => 'udp',
        :format => 9999 }
      @media_description_field.valid?.should be_true
    end

    it "is NOT valid when :media is empty" do
      @media_description_field.value = { :media => '',
        :port => 678,
        :protocol => 'RTP',
        :format => 9 }
      @media_description_field.valid?.should be_false
    end

    it "is NOT valid when :port is empty" do
      @media_description_field.value = { :media => 'text',
        :port => '',
        :protocol => 'udp',
        :format => 91 }
      @media_description_field.valid?.should be_false
    end

    it "is NOT valid when :protocol is empty" do
      @media_description_field.value = { :media => 'message',
        :port => 9091,
        :protocol => '',
        :format => 3 }
      @media_description_field.valid?.should be_false
    end

    it "is NOT valid when :format is empty" do
      @media_description_field.value = { :media => 'message',
        :port => 9091,
        :protocol => 'RTP/SAVP',
        :format => '' }
      @media_description_field.valid?.should be_false
    end
  end
end
