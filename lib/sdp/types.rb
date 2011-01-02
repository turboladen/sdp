require 'ostruct'

class SDP
  module Types
    Version = Integer
    SessionName = String
    Origin = Struct.new(:username, :session_id, :session_version,
      :net_type, :address_type, :unicast_address)
    #Origin = OpenStruct.new(:username=>"sl", :session_id=>"", :session_version=>"",
    #  :net_type=>"", :address_type=>"", :unicast_address=>"")
    Timing = Struct.new(:start_time, :stop_time)
    MediaDescription = Struct.new(:media, :port, :protocol, :format)
  end
end