Feature: Get SDP file fields and marshall into Ruby data types
  As an RTSP consumer
  I want to be able to be able to read SDP files into Ruby data types
  So that it's easy to determine how to work with the RTSP stream
  
  Scenario: Parse the RFC 4566 example
    Given the RFC 4566 SDP example in a file
    When I parse the file
    Then the <value> for <field> is accessible via the SDP object
      | field             | value             |
      | protocol_version  | 0                 |
      | username          | jdoe              |
      | id                | 2890844526        |
      | version           | 2890842807        |
      | network_type      | IN                |
      | address_type      | IP4               |
      | unicast_address   | 10.47.16.5        |
      | name              | SDP Seminar       |
      | information       | A Seminar on the session description protocol |
      | uri               | http://www.example.com/seminars/sdp.pdf |
      | email_address     | j.doe@example.com (Jane Doe)            |
      | connection_address | 224.2.17.12/127  |
      | start_time        | 2873397496        |
      | stop_time         | 2873404696        |
      | attributes        | recvonly          |
#      | m[0][1] | 49170               |
#      | m[0][2] | "RTP/AVP"           |
#      | m[0][3] | 0                   |
#      | m[1][1] | 51372               |
#      | m[1][2] | "RTP/AVP"           |
#      | m[1][3] | 99                  |
#      | a[1][1] | 99        |
#      | a[1][2] | "h263-1998" |
#      | a[1][3] | 90000     |

