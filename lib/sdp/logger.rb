require 'log_switch'

class SDP
  class Logger
    extend LogSwitch
  end
end

SDP::Logger.log_class_name = true
SDP::Logger.log = false
