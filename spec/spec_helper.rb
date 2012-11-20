require 'simplecov'
SimpleCov.start

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sdp/version'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }
include TestDescriptions
