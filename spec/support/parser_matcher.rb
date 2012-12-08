require 'spec_helper'
require 'sdp'


RSpec::Matchers.define :parse do |expected|
  match do
    begin
      result = SDP::Description.parse(expected)
    rescue SDP::ParseError => ex
      puts ex
      raise
    end

    result
  end
end

RSpec::Matchers.define :be_a_valid_description do |expected|
  match do |actual|
    @result = if actual.kind_of? SDP::FieldGroup
      actual
    else
      SDP::Description.parse(actual)
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

