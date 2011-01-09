Feature: Get SDP file fields and marshall into Ruby data types
  As an RTSP consumer
  I want to be able to be able to read SDP files into Ruby data types
  So that it's easy to determine how to work with the RTSP stream
  
  Scenario: Parse the RFC 4566 example
    Given the RFC 4566 SDP example in a file
    When I parse the file
    Then the <value> for <field> is accessible via the SDP object
      | field | parameter | value                       |
      | version     |   | 0                           |
      | origin      | username  | jdoe        |
#      | o  | "jdoe"                      |
#      | o  | 2890844526                  |
#      | o  | 2890842807             |
#      | o[3]  | "IN"                        |
#      | o[4]  | "IP4"                     |
#      | o[5]  | "10.47.16.5"           |
#      | s     | "SDP Seminar"               |
#      | i     | "A Seminar on the session description protocol" |
#      | u     | "http://www.example.com/seminars/sdp.pdf" |
#      | e     | j.doe@example.com (Jane Doe) |
#      | c[0]  | "IN"            |
#      | c[1]  | "IP4"           |
#      | c[2]  | "224.2.17.12/127" |
#      | t[0]  | 2873397496          |
#      | t[1]  | 2873404696          |
#      | a[0]  | true                |
#      | m[0][1] | 49170               |
#      | m[0][2] | "RTP/AVP"           |
#      | m[0][3] | 0                   |
#      | m[1][1] | 51372               |
#      | m[1][2] | "RTP/AVP"           |
#      | m[1][3] | 99                  |
#      | a[1][1] | 99        |
#      | a[1][2] | "h263-1998" |
#      | a[1][3] | 90000     |

