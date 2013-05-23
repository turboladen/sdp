require_relative 'string_case_conversions'


class Class

  # Returns the name of the lowest level class as a snake-case Symbol.
  #
  # @example
  #   SDP::Fields::TimeZoneAdjustments.sdp_type   # => :time_zone_adjustments
  #
  # @return [Symbol]
  def sdp_type
    klass_name = name.split('::').last

    klass_name.snake_case.to_sym
  end
end
