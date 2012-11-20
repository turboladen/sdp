module TestDescriptions
  REQUIRED_ONLY = %{v=0\r
o=guy 1234 5555 IN IP4 123.33.22.123\r
s=This is a test session\r
c=IN IP4 0.0.0.0\r
t=11111 22222\r
}

#-------------------------------------------------------------------------------
# Missing lines
#-------------------------------------------------------------------------------
  NO_VERSION = %{o=- 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
c=IN IP4 0.0.0.0\r
t=0 0\r
}

  NO_ORIGIN = %{v=0\r
s=Test session\r
c=IN IP4 0.0.0.0\r
t=0 0\r
}

  NO_NAME = %{v=0\r
o=- 1809368942 3379601213 IN IP4 127.0.0.1\r
c=IN IP4 0.0.0.0\r
t=0 0\r
}

  NO_CONNECT = %{v=0\r
o=guy 1234 5555 IN IP4 123.33.22.123\r
s=This is a test session\r
t=11111 22222\r
}

  NO_TIMING = %{v=0\r
o=- 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
c=IN IP4 0.0.0.0\r
}


  TWO_TIME_DESCRIPTIONS = %{v=0\r
o=user 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
t=0 0\r
t=1 2\r
}

  ONE_MEDIA_SECTION_NO_CONNECT = %{v=0\r
o=person 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
t=1234 5678\r
m=audio 0 RTP/AVP 96\r
}

  ONE_MEDIA_SECTION_CONNECT_IN_SESSION = %{v=0\r
o=person 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
c=IN IP4 0.0.0.0\r
t=1234 5678\r
m=audio 0 RTP/AVP 96\r
}

  ONE_MEDIA_SECTION_CONNECT_IN_MEDIA = %{v=0\r
o=person 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
t=1234 5678\r
m=audio 0 RTP/AVP 96\r
c=IN IP4 0.0.0.0\r
}

  TWO_MEDIA_SECTIONS_NO_CONNECT = %{v=0\r
o=person 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
t=1234 5678\r
m=audio 0 RTP/AVP 96\r
m=audio 0 RTP/AVP 97\r
}

  TWO_MEDIA_SECTIONS_CONNECT_IN_SESSION = %{v=0\r
o=person 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
c=IN IP4 0.0.0.0\r
t=1234 5678\r
m=audio 0 RTP/AVP 96\r
m=audio 0 RTP/AVP 97\r
}

  TWO_MEDIA_SECTIONS_CONNECT_IN_MEDIA = %{v=0\r
o=person 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Test session\r
t=1234 5678\r
m=audio 0 RTP/AVP 96\r
c=IN IP4 0.0.0.0\r
m=audio 0 RTP/AVP 97\r
c=IN IP4 0.0.0.0\r
}

  SDP_MISSING_TIME = %Q{v=0\r
o=- 1809368942 3379601213 IN IP4 127.0.0.1\r
s=Secret Agent from SomaFM\r
i=Downtempo Spy Lounge\r
c=IN IP4 0.0.0.0\r
t=0 0\r
a=x-qt-text-cmt:Orban Opticodec-PCx-qt-text-nam:Secret Agent from SomaFMx-qt-text-inf:Downtempo Spy Loungecontrol:*\r
m=audio 0 RTP/AVP 96\r
a=rtpmap:96 MP4A-LATM/44100/2a=fmtp:96 cpresent=0;config=400027200000a=control:trackID=1\r
}
end
