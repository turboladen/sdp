require 'sdp_spec'

describe SDP do
  before do
    @sdp = SDP.new
  end

  it ""
=begin
  context "#initialize defaults" do
    it "initializes :version to 0" do
      @sdp[:version].should == 0
    end

    context ":origin" do
      it "initializes :origin as a Hash" do
        @sdp[:origin].class.should == Hash
      end

      it "initializes :origin[:username] to be my username" do
        @sdp[:origin][:username].should == Etc.getlogin
      end

      it "initializes :origin[:session_id] to be an NTP timestamp" do
        @sdp[:origin][:session_id].class.should == Fixnum
      end

      it "initializes :origin[:session_version] to be an NTP timestamp" do
        @sdp[:origin][:session_version].class.should == Fixnum
      end

      it "initializes :origin[:net_type] to be 'IN'" do
        @sdp[:origin][:net_type].class.should == String
        @sdp[:origin][:net_type].should == "IN"
      end

      it "initializes :origin[:address_type] to be :IP4" do
        @sdp[:origin][:address_type].class.should == Symbol
        @sdp[:origin][:address_type].should == :IP4
      end

      it "initializes :origin[:unicast_address] to be the local IP" do
        @sdp[:origin][:unicast_address].class.should == String
        @sdp[:origin][:unicast_address].should == @sdp.get_local_ip
      end
    end

    it "initializes :session_name to ' '" do
      @sdp[:session_name].should == ' '
    end

    context ":timing" do
      it "initializes :timing as a Hash" do
        @sdp[:timing].class.should == Hash
      end

      it "initializes :timing[:start_time] to be an NTP timestamp" do
        @sdp[:timing][:start_time].class.should == Fixnum
      end

      it "initializes :timing[:stop_time] to be an NTP timestamp" do
        @sdp[:timing][:stop_time].class.should == Fixnum
      end
    end

    context ":media_description" do
      it "initializes :media_description as a Hash" do
        @sdp[:media_description].class.should == Hash
      end
    end
  end
=end
end