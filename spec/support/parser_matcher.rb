RSpec::Matchers.define :parse do |expected|
  match do
    begin
      result = SDP::Parser.new.parse(expected)
    rescue Parslet::ParseFailed => ex
      puts ex
      raise
    end

    result
  end
end

RSpec::Matchers.define :be_a_valid_description do |expected|
  match do |actual|
    @result = if actual.is_a? SDP::Description
      actual
    else
      SDP::Description.new(actual)
    end

    @result.valid?
  end

  failure_message_for_should do
    "Expected had errors: #{@result.errors}"
  end

  failure_message_for_should_not do
    "Expected description not be valid, but it was. #{@result.inspect}"
  end
end

