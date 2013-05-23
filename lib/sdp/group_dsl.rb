class SDP
  module GroupDSL
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

    module DSLMethods
      def allowed_field_types(*types)
        @allowed_field_types ||= []
        return @allowed_field_types if types.empty?

        check_field_types(types)
        @allowed_field_types = types
      end

      def required_field_types(*types)
        @required_field_types ||= []
        return @required_field_types if types.empty?

        check_field_types(types)
        @required_field_types = types
      end

      def allowed_group_types(*types)
        @allowed_group_types ||= []
        return @allowed_group_types if types.empty?

        check_field_types(types)
        @allowed_group_types = types
      end

      def required_group_types(*types)
        @required_group_types ||= []
        return @required_group_types if types.empty?

        check_field_types(types)
        @required_group_types = types
      end

      def line_order(*types)
        @line_order ||= []
        return @line_order if types.empty?

        check_field_types(types)
        @line_order = types
      end

      def allow_multiple
        @allow_multiple = true
      end

      def allows_multiple?
        !!defined?(@allow_multiple)
      end

      private

      def check_field_types(types)
        if types.any? { |type| !type.is_a? Symbol }
          raise "Field types must be Symbols"
        end
      end
    end
  end
end
