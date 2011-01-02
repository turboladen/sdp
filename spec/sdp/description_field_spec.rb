require File.dirname(__FILE__) + '/../spec_helper'
require 'sdp/description_field'

describe SDP::DescriptionField do
  it "takes :version and 0 as a field type and value" do
    d = SDP::DescriptionField.new(:version, 0)
    d.type.should == :version
    d.value.should == 0
    d.required.should == true
  end

  it "takes 'v' and '0' as a field type and value" do
    d = SDP::DescriptionField.new('v', '0')
    d.type.should == :version
    d.value.should == 0
    d.required.should == true
  end

=begin
  it "takes :origin[:username] and 'jdoe' as a field type and value" do
    d = SDP::DescriptionField.new(:origin[:username], 'jdoe')
    d.type.should ==
  end
=end
  it "takes :media_description and { :media => :audio } as type and value" do
    d = SDP::DescriptionField.new(:media_description, { :media => :audio } )
    d.type.should == :media_description
    d.value[:media].should == :audio
  end
end