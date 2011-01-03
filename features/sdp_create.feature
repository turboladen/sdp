Feature: Programmatically create an SDP file
  As a utility using SDP to describe a multimedia session
  I want to be able to turn Ruby code in to an SDP description,
    as specified in RFC 4566
  So that I can use Ruby to describe the multimedia session

  Scenario: Create an SDP file from a Ruby object
    Given I know what the SDP file should look like
    When I build the Ruby object with the appropriate fields
    Then the resulting file should look like the intended description

  Scenario: Create a basic SDP object
    Given I create an SDP object with no parameters
    When I convert it to a String
    Then it should have :version set to 0
    And it should have all :origin fields set
