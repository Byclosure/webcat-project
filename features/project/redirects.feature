Feature: Project Redirects
  Background:
    Given public project "Community"
    And private project "Enterprise"

  Scenario: I visit public project page
    When I visit project "Community" page
    Then I should see project "Community" home page

  Scenario: I visit private project page
    When I visit project "Enterprise" page
    Then I should be redirected to sign in page

  Scenario: I visit a non-existent project page
    When I visit project "CommunityDoesNotExist" page
    Then I should be redirected to sign in page

  Scenario: I visit a non-existent project page as user
    Given I sign in as a user
    When I visit project "CommunityDoesNotExist" page
    Then page status code should be 404

  Scenario: I visit unauthorized project page as user
    Given I sign in as a user
    When I visit project "Enterprise" page
    Then page status code should be 404
