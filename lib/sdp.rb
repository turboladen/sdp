require File.expand_path(File.dirname(__FILE__) + '/sdp/version')
require File.expand_path(File.dirname(__FILE__) + '/sdp/description')
require File.expand_path(File.dirname(__FILE__) + '/sdp/parser')
require File.expand_path(File.dirname(__FILE__) + '/sdp/parse_error')

# The only use for this class is the #parse method, which is in this
# base class solely for convenience.  Other than this method, this
# base class doesn't really do anything.
class SDP

  # Creates a parser and parses the given text in to an SDP::Description
  # object.
  #
  # @param [String] sdp_text The text from an SDP description.
  # @return [SDP::Description] The object that represents the description
  #   that was parsed.
  # @raise [SDP::ParseError] If parsing fails, raise an SDP::ParseError instead
  #   of a Parslet exception that might confuse SDP users.
  def self.parse sdp_text
    begin
      sdp_hash = SDP::Parser.new.parse sdp_text
    rescue Parslet::UnconsumedInput => ex
      raise SDP::ParseError, ex
    end

    SDP::Description.new(sdp_hash)
  end
end
