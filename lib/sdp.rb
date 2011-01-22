require 'sdp/version'
require 'sdp/description'
require 'sdp/parser'

# The only use for this class is the #parse method, which is in this
# base class solely for convenience.  Other than this method, this
# base class doesn't really do anything.
class SDP

  # Creates a parser and parses the given text in to an SDP::Description
  # object.
  #
  # @param [String] sdp_text The text from an SDP description.
  # @return [SDP::Description] The object that represents the description
  # that was parsed.
  def self.parse sdp_text
    sdp_hash = SDP::Parser.new.parse sdp_text
    SDP::Description.new(sdp_hash)
  end
end

# Reclass so we can raise our own Exceptions.
class SDP::RuntimeError < StandardError; end;
