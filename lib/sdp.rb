require 'etc'
require 'net/ntp'
require 'sdp/version'
require 'sdp/types'
require 'sdp/description_field'
#require 'sdp/parser'

class SDP < Hash
  #include SDP::Parser
  include SDP::Types

  SDP_VERSION = 0
  attr_reader :bob

  # TODO: The origin <username> MUST NOT contain spaces.
  # TODO: Its
  #      usage is up to the creating tool, so long as <sess-version> is
  #      increased when a modification is made to the session data.  Again,
  #      it is RECOMMENDED that an NTP format timestamp is used.
  def initialize fields={}
    #@bob = MediaDescription.new(:audio, 49170, "RTP/AVP", 0)
    self[:version]            = SDP_VERSION
    self[:origin]             = "#{Etc.getlogin}"
    self[:session_name]       = " "
    self[:timing]             = "0 0"
    self[:media_description]  = ""
=begin
    self[:version]                    = SDP_VERSION   || fields[:version]
    self[:origin] = Hash.new
    self[:origin][:username]          = Etc.getlogin  || fields[:username]
    ntp = Net::NTP.get
    self[:origin][:session_id] = ntp.receive_timestamp.to_i  || fields[:origin][:session_id]
    self[:origin][:session_version] = ntp.receive_timestamp.to_i || fields[:origin][:session_version]
    self[:origin][:net_type]          = 'IN'          || fields[:origin][:net_type]
    self[:origin][:address_type]      = :IP4          || fields[:origin][:address_type]
    self[:origin][:unicast_address]   = get_local_ip  || fields[:origin][:unicast_address]
    self[:session_name]               = " "           || fields[:session_name]
    self[:timing] = Hash.new
    self[:timing][:start_time]        = ntp.receive_timestamp.to_i || fields[:timing][:start_time]
    self[:timing][:stop_time]        = ntp.receive_timestamp.to_i || fields[:timing][:stop_time]
    self[:media_description] = Hash.new
=end
  end

  def get_local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

=begin
  def [](field_type)
    begin
      eval "[#{field_type}]"
    rescue NameError
      field = DescriptionField.new(field_type)
      store(field.ruby_type, field)
    else
      super
    end
  end
=end

  def []=(field_type, field_value)
    field = DescriptionField.new(field_type, field_value)
    store(field.ruby_type, field)
  end

  def to_s
    sdp_string = self[:version].to_sdp_s
    sdp_string << self[:origin].to_sdp_s
    sdp_string << self[:session_name].to_sdp_s
    sdp_string << self[:timing].to_sdp_s
    sdp_string << self[:media_description].to_sdp_s
  end
end
