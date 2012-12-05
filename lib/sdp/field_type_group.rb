require_relative 'runtime_error'


class SDP
  class FieldTypeGroup
    attr_reader :lines

    def initialize(init_data=nil)
      @lines = []
      return unless init_data

      if init_data.is_a? String
        init_data.each_line { |line| add_line(line) }
      elsif init_data.is_a? Array
        init_data.each { |line| add_line(line) }
      end
    end

    def add_line(line_data)
      group_klass_name = self.class.name.split("::").last
      klass = SDP::FieldTypes.const_get "#{group_klass_name}Line"
      line = klass.new(line_data)

      if line_data.match /^#{line.prefix}=/
        @lines << line
      else
        raise SDP::RuntimeError, "#add_line was given data for another field type"
      end
    end

    def to_s
      @lines.map(&:to_s).join
    end

    def each
      @lines.each do |line|
        yield line if block_given?
      end
    end
  end
end
