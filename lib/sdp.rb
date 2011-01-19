require 'sdp/version'
require 'sdp/description'
require 'sdp/parser'

class SDP
  PROTOCOL_VERSION = 0
  
  def self.parse sdp_text
		sdp_hash = SDP::Parser.new.parse sdp_text
    session = SDP::Description.new(sdp_hash)
  end
end

class SDP::RuntimeError < StandardError; end;
