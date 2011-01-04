require File.dirname(__FILE__) + '/../../spec_helper'
require 'sdp/description_fields/origin_field'

describe SDP::DescriptionFields::OriginField do
  context "#initialize" do
    before do
      @origin_field = SDP::DescriptionFields::OriginField.new
    end

    it "sets :sdp_type to 'o'" do
      @origin_field.sdp_type.should == 'o'
    end

    it "sets :ruby_type to :origin" do
      @origin_field.ruby_type.should == :origin
    end

    it "sets :required to true" do
      @origin_field.required.should be_true
    end

    it "sets :value[:username] to the current username" do
      @origin_field.value[:username].should == Etc.getlogin
    end

    it "sets :value[:session_id] to a Number" do
      @origin_field.value[:session_id].class.should == Fixnum
    end

    it "sets :value[:session_version] to a Number" do
      @origin_field.value[:session_version].class.should == Fixnum
    end

    it "sets :value[:net_type] to :IN" do
      @origin_field.value[:net_type].should == :IN
    end

    it "sets :value[:address_type] to :IP4" do
      @origin_field.value[:address_type].should == :IP4
    end

    it "sets :value[:unicast_address] to the current local IP" do
      @origin_field.value[:unicast_address].should == @origin_field.get_local_ip
    end

    it "is valid" do
      @origin_field.valid?.should be_true
    end
  end

  context "working with the object" do
    def validate_settings(new_values)
      before_values = @origin_field.value
      @origin_field.value = new_values
      @origin_field.value.each_key do |key|
        if new_values.has_key?(key)
          @origin_field.value[key].should == new_values[key]
        else
          @origin_field.value[key].should == before_values[key]
        end
      end
    end

    before :each do
      @origin_field = SDP::DescriptionFields::OriginField.new
    end

    context "values" do
      it "can accept a new value of :username => me" do
        validate_settings :username => "me"
      end

      it "can accept a new value of :session_id => 1" do
        validate_settings :session_id => 1
      end

      it "can accept a new value of :session_version => 2" do
        validate_settings :session_version => 2
      end

      it "can accept a new value of :net_type => :BO" do
        validate_settings :net_type => :BO
      end

      it "can accept a new value of :address_type => :IP6" do
        validate_settings :address_type => :IP6
      end

      it "can accept a new value of :unicast_address => '1.2.3.4'" do
        validate_settings :unicast_address => '1.2.3.4'
      end

      it "can accept new value of 'me', 1, 2, :BO, :IP6, '1.2.3.4'" do
        new_values = { :username => 'me',
          :session_id => 1,
          :session_version => 2,
          :net_type => :BO,
          :address_type => :IP6,
          :unicast_address => '1.2.3.4' }
        @origin_field.value = new_values
        @origin_field.value.should == new_values
      end

      it "can accept new value of 'bobo', 23, :IP98" do
        new_values = { :username => 'bobo',
          :session_version => 23,
          :address_type => :IP98 }
        validate_settings new_values
      end
    end

    it "outputs a string of 'o=me 12345 9876 FLOSS IP321 4.4.2.2'" do
      @origin_field.value = { :username => "me",
        :session_id => 12345,
        :session_version => 9876,
        :net_type => :FLOSS,
        :address_type => :IP321,
        :unicast_address => '4.4.2.2' }
      @origin_field.to_sdp_s.should == "o=me 12345 9876 FLOSS IP321 4.4.2.2\r\n"
    end

    it "is valid after setting values" do
      @origin_field.value = { :username => "me",
        :session_id => 12345,
        :session_version => 9876,
        :net_type => :FLOSS,
        :address_type => :IP321,
        :unicast_address => '4.4.2.2' }
      @origin_field.valid?.should be_true
    end

    it "is NOT valid when :username is empty" do
      @origin_field.value = { :username => '',
        :session_id => 678,
        :session_version => 9 }
      @origin_field.valid?.should be_false
    end

    it "is NOT valid when :session_id is empty" do
      @origin_field.value = { :username => "elvis",
        :session_id => '',
        :session_version => 9999999 }
      @origin_field.valid?.should be_false
    end

    it "is NOT valid when :session_version is empty" do
      @origin_field.value = { :username => "elvis",
        :session_id => 99118822,
        :session_version => "" }
      @origin_field.valid?.should be_false
    end
  end
end
