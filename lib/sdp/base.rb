class SDP
  class Base
    def to_s
      unless valid?
        warn "#to_s called on a #{self.class} without required info added: #{errors}"
      end
    end

    def to_hash
      warn "#to_hash called on #{self.class} but must be implemented in child"
    end

    def valid?
      errors.empty?
    end

    def errors
      warn "#errors called on #{self.class} but must be implemented in child"
    end

    # Returns the name of the lowest level class as a snake-case Symbol.
    #
    # @example
    #   SDP::Fields::TimeZoneAdjustments.sdp_type   # => :time_zone_adjustments
    #
    # @return [Symbol]
    def sdp_type
      self.class.sdp_type
    end

    # Hook method defined for children to redefine if desired.
    def seed!
      warn "#seed! called on #{self.class} but must be implemented in child"
    end

    # This custom redefinition of #inspect is needed because of the #to_s
    # definition.
    #
    # @return [String]
    def inspect
      me = "#<#{self.class.name}:0x#{self.object_id.to_s(16)}"

      ivars = self.instance_variables.map do |variable|
        "#{variable}=#{instance_variable_get(variable).inspect}"
      end.join(' ')

      me << " #{ivars} " unless ivars.empty?
      me << ">"

      me
    end
  end
end
