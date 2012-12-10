require 'simplecov'
SimpleCov.start

$:.unshift(File.dirname(__FILE__) + '/../lib')

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }
include TestDescriptions

require 'sdp/logger'
SDP::Logger.log = false
