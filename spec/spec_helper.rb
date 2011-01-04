require 'rspec'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sdp/version'

def validate_settings(existing_field, new_values)
  before_values = existing_field.value
  existing_field.value = new_values
  existing_field.value.each_key do |key|
    if new_values.has_key?(key)
      existing_field.value[key].should == new_values[key]
    else
      existing_field.value[key].should == before_values[key]
    end
  end
end
