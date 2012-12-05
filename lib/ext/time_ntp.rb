class Time

  # Converts Unix time to NTP time.
  def to_ntp
    ntp_to_unix_time_diff = 2208988800
    self.to_i + ntp_to_unix_time_diff
  end
end
