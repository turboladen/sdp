Feature: Accept description as a String
  As an SDP user
  I want to be able to parse a String of an SDP description
  (that I received from a server, perhaps) and turn it into Ruby
  objects
  So that I can more easily work with each piece of the description

  Scenario: Description without time zone fields
    Given a description with no time zone fields
    When I parse the description
    Then I can access the protocol_version field value
    And put the description back to a String
