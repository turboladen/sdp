require 'sdp/description'
require 'sdp/description_parser'

class SDP
  module Parser
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def parse sdp_text
				sdp_hash = SDP::DescriptionParser.new.parse sdp_text
        session = SDP::Description.new(sdp_hash)
      end
    end
  end
end