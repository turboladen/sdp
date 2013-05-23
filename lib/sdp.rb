require_relative 'sdp/version'
require_relative 'sdp/description'


# The only use for this class is the +#parse+ method, which is in this
# base class solely for convenience.
class SDP

  # Parses the given text in to an +SDP::Description+ object.
  #
  # @param [String] sdp_text The text from an SDP description.
  # @return [SDP::Description] The object that represents the description
  #   that was parsed.
  # @raise [SDP::ParseError] If parsing fails, raise an SDP::ParseError instead
  #   of a Parslet exception that might confuse SDP users.
  def self.parse sdp_text
    SDP::Description.parse(sdp_text)
  end
end
