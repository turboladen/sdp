require 'simplecov'
SimpleCov.start

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sdp/version'

SDP_MISSING_TIME = "v=0\r\no=- 1809368942 3379601213 IN IP4 127.0.0.1\r\ns=Secret Agent from SomaFM\r\ni=Downtempo Spy Lounge\r\nc=IN IP4 0.0.0.0\r\nt=0 0\r\na=x-qt-text-cmt:Orban Opticodec-PCx-qt-text-nam:Secret Agent from SomaFMx-qt-text-inf:Downtempo Spy Loungecontrol:*\r\nm=audio 0 RTP/AVP 96\r\na=rtpmap:96 MP4A-LATM/44100/2a=fmtp:96 cpresent=0;config=400027200000a=control:trackID=1\r\n"
