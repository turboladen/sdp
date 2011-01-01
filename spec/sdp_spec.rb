require 'spec_helper'
require 'sdp'

describe Sdp do
  it "should have a VERSION constant" do
    Sdp.const_get('VERSION').should_not be_empty
  end
end
