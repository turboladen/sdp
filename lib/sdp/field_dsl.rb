class SDP
  module FieldDSL
    def self.included(base)
      base.extend(DSLMethods)
    end

    # Provides an easier way for the includer to get to the DSLMethods.  Allows
    # for:
    #   t = SDP::Groups::TimingDescription.new
    #   t.settings.allowed_field_types    # => [:timing, :repeat_times]
    #   t.settings.required_field_types    # => [:timing]
    def settings
      if @settings.nil?
        includer = self.class
        @settings = Object.new

        DSLMethods.instance_methods.each do |m|
          @settings.define_singleton_method(m) do
            includer.send(m)
          end
        end
      end

      @settings
    end

    def prefix
      settings.prefix
    end

    module DSLMethods
      # Defines a special attr_accessor.  This separates out values (these) that
      # make up a field from any other instance variables that a Field might
      # define.
      #
      # @param [Symbol] value
      # @param [Boolean] optional Set to +true+ if the value is optional for
      #   the field.  This will keep Fields from complaining if this value isn't
      #   set.
      def field_value(value, optional=false)
        raise "value must be a Symbol" unless value.is_a? Symbol

        @field_values ||= []
        @field_values << value

        @optional_field_values ||= []
        @optional_field_values << value if optional

        define_method value do
          instance_variable_get("@#{value}".to_sym)
        end

        define_method "#{value}=" do |new_value|
          instance_variable_set("@#{value}".to_sym, new_value)
        end
      end

      # The list of all field values defined for the Field.
      #
      # @return [Array<Symbol>] All of the field values defined for the Field.
      def field_values
        @field_values ||= []
      end

      # The list of all optional field values defined for the Field.
      #
      # @return [Array<Symbol>] All of the optional field values defined for the
      #   Field.
      def optional_field_values
        @optional_field_values ||= []
      end

      # The letter that represents the field line in a description (i.e. "v"
      # represents Protocol Version).
      #
      # @param [String] char The character that represents the field.
      # @return [String] The character.
      def prefix(char=nil)
        return @prefix if char.nil?
        raise "Can't change prefix after it has been set" if defined? @prefix

        @prefix = char
      end

      def allow_multiple
        @allow_multiple = true
      end

      def allows_multiple?
        !!defined?(@allow_multiple)
      end
    end
  end
end
