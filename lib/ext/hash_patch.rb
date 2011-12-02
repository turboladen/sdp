class Hash
  # Converts keys to Strings.  Useful for dealing with +SDP::Parser+ results
  # (which subclasses +Parslet::Parser+), which returns +Parslet::Slice+ objects
  # in place of +String+ objects, which isn't helpful in this case.
  #
  # @return [Hash] +self+, but with Strings instead of Parslet::Slices.
  def keys_to_s
    self.each do |k, v|
      case v
      when Hash
        v.keys_to_s
      when Array
        v.each do |element|
          element.keys_to_s if element.is_a? Hash
        end
      else
        self[k] = v.to_s
      end
    end

    self
  end
end
