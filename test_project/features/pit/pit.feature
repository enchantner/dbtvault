@fixture.set_workdir
Feature: pit

  @fixture.pit
  Scenario: Load into a pit table where the AS IS table is already established and the AS_IS table has increments of a week
    Given the PIT table does not exist
    And the raw vault contains empty tables
      | HUBS         | LINKS | SATS                       | T_LINKS | EFF_SATS | PIT          |
      | HUB_CUSTOMER |       | SAT_CUSTOMER_DETAILS_APP   |         |          | PIT_CUSTOMER |
      |              |       | SAT_CUSTOMER_DETAILS_WEB   |         |          |              |
      |              |       | SAT_CUSTOMER_DETAILS_PHONE |         |          |              |
    And the RAW_STAGE_DETAILS table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_ADDRESS                 | CUSTOMER_DOB | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 1 Forrest road Hampshire FK3 4OC | 1997-04-24   | 2019-01-01 00:00:00.000000 | App    |
      | 1002        | Bob           | 1 Forrest road Hampshire FK3 4OC | 2006-04-17   | 2019-01-01 00:00:00.000000 | App    |
      | 1002        | Bob           | 1 Forrest road Hampshire FK3 4OC | 2006-04-17   | 2019-01-08 00:00:00.000000 | App    |
      | 1002        | Bob           | 1 Forrest road Hampshire FK3 4OC | 2006-04-17   | 2019-01-20 00:00:00.000000 | App    |
    And I create the STG_CUSTOMER_DETAILS stage
    And the RAW_STAGE_WEB table contains data
      | CUSTOMER_ID | LAST_LOGIN_DATE            | DEVICE_USED | LOAD_DATE                  | SOURCE |
      | 1001        | 2019-01-01 02:00:00.000000 | Phone       | 2019-01-02 00:00:00.000000 | WEB    |
      | 1001        | 2019-01-02 03:00:00.000000 | Phone       | 2019-01-03 00:00:00.000000 | WEB    |
      | 1001        | 2019-01-03 01:00:00.000000 | Laptop      | 2019-01-04 00:00:00.000000 | WEB    |
      | 1002        | 2019-01-01 05:00:00.000000 | Tablet      | 2019-01-02 00:00:00.000000 | WEB    |
      | 1002        | 2019-01-02 06:00:00.000000 | Tablet      | 2019-01-03 00:00:00.000000 | WEB    |
      | 1002        | 2019-01-03 08:00:00.000000 | Tablet      | 2019-01-04 00:00:00.000000 | WEB    |
    And I create the STG_CUSTOMER_WEB stage
    And the RAW_STAGE_PHONE table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | 2019-01-06 00:00:00.000000 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Manchester        | 2019-01-10 00:00:00.000000 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Paris             | 2019-01-20 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | 2019-01-03 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Austin            | 2019-01-07 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Fort Worth        | 2019-01-15 00:00:00.000000 | Phone  |
    And I create the STG_CUSTOMER_PHONE stage
    And the AS_OF_DATE table contains data
      | AS_OF_DATE                 |
      | 2019-01-07 00:00:00.000000 |
      | 2019-01-14 00:00:00.000000 |
      | 2019-01-21 00:00:00.000000 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the HUB_CUSTOMER table should contain expected data
      | CUSTOMER_PK | CUSTOMER_ID | LOAD_DATE                  | SOURCE |
      | md5('1001') | 1001        | 2019-01-01 00:00:00.000000 | App    |
      | md5('1002') | 1002        | 2019-01-01 00:00:00.000000 | App    |
    Then the SAT_CUSTOMER_DETAILS_APP table should contain expected data
      | CUSTOMER_PK | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | HASHDIFF                                      | EFFECTIVE_FROM | LOAD_DATE                  | SOURCE |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | md5('PORTSMOUTH\|\|ALICE\|\|17-214-233-1214') | 2019-01-01     | 2019-01-01 00:00:00.000000 | App    |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Liverpool         | md5('LIVERPOOL\|\|ALICE\|\|17-214-233-1214')  | 2019-01-12     | 2019-01-12 00:00:00.000000 | App    |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Glasgow           | md5('GLASGOW\|\|ALICE\|\|17-214-233-1214')    | 2019-01-16     | 2019-01-16 00:00:00.000000 | App    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | md5('NEW YORK\|\|BOB\|\|17-214-233-1215')     | 2019-01-01     | 2019-01-01 00:00:00.000000 | App    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | Phoenix           | md5('PHOENIX\|\|BOB\|\|17-214-233-1215')      | 2019-01-08     | 2019-01-08 00:00:00.000000 | App    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | San Diego         | md5('SAN DIEGO\|\|BOB\|\|17-214-233-1215')    | 2019-01-20     | 2019-01-20 00:00:00.000000 | App    |
    Then the SAT_CUSTOMER_DETAILS_WEB table should contain expected data
      | CUSTOMER_PK | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | HASHDIFF                                      | EFFECTIVE_FROM | LOAD_DATE                  | SOURCE |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | London            | md5('LONDON\|\|ALICE\|\|17-214-233-1214')     | 2019-01-04     | 2019-01-04 00:00:00.000000 | WEB    |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Birmingham        | md5('BIRMINGHAM\|\|ALICE\|\|17-214-233-1214') | 2019-01-08     | 2019-01-08 00:00:00.000000 | WEB    |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Dublin            | md5('DUBLIN\|\|ALICE\|\|17-214-233-1214')     | 2019-01-19     | 2019-01-19 00:00:00.000000 | WEB    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | Dallas            | md5('DALLAS\|\|BOB\|\|17-214-233-1215')       | 2019-01-06     | 2019-01-06 00:00:00.000000 | WEB    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | El Paso           | md5('EL PASO\|\|BOB\|\|17-214-233-1215')      | 2019-01-09     | 2019-01-09 00:00:00.000000 | WEB    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | Las Vegas         | md5('LAS VEGAS\|\|BOB\|\|17-214-233-1215')    | 2019-01-19     | 2019-01-19 00:00:00.000000 | WEB    |
    Then the SAT_CUSTOMER_DETAILS_PHONE table should contain expected data
      | CUSTOMER_PK | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | HASHDIFF                                      | EFFECTIVE_FROM | LOAD_DATE                  | SOURCE |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | md5('SWANSEA\|\|ALICE\|\|17-214-233-1214')    | 2019-01-06     | 2019-01-06 00:00:00.000000 | Phone  |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Manchester        | md5('MANCHESTER\|\|ALICE\|\|17-214-233-1214') | 2019-01-10     | 2019-01-10 00:00:00.000000 | Phone  |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Paris             | md5('PARIS\|\|ALICE\|\|17-214-233-1214')      | 2019-01-20     | 2019-01-20 00:00:00.000000 | Phone  |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | md5('WASHINGTON\|\|BOB\|\|17-214-233-1215')   | 2019-01-03     | 2019-01-03 00:00:00.000000 | Phone  |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | Austin            | md5('AUSTIN\|\|BOB\|\|17-214-233-1215')       | 2019-01-07     | 2019-01-07 00:00:00.000000 | Phone  |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | Fort Worth        | md5('FORT WORTH\|\|BOB\|\|17-214-233-1215')   | 2019-01-15     | 2019-01-15 00:00:00.000000 | Phone  |
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_APP_PK | SAT_CUSTOMER_DETAILS_APP_LDTS | SAT_CUSTOMER_DETAILS_WEB_PK | SAT_CUSTOMER_DETAILS_WEB_LDTS | SAT_CUSTOMER_DETAILS_PHONE_PK | SAT_CUSTOMER_DETAILS_PHONE_LDTS |
      | md5('1002') | 2019-01-07 00:00:00.000000 | md5('1002')                 | 2019-01-01 00:00:00.000000    | md5('1002')                 | 2019-01-06 00:00:00.000000    | md5('1002')                   | 2019-01-07 00:00:00.000000      |
      | md5('1002') | 2019-01-14 00:00:00.000000 | md5('1002')                 | 2019-01-08 00:00:00.000000    | md5('1002')                 | 2019-01-09 00:00:00.000000    | md5('1002')                   | 2019-01-07 00:00:00.000000      |
      | md5('1002') | 2019-01-21 00:00:00.000000 | md5('1002')                 | 2019-01-20 00:00:00.000000    | md5('1002')                 | 2019-01-19 00:00:00.000000    | md5('1002')                   | 2019-01-15 00:00:00.000000      |
      | md5('1001') | 2019-01-07 00:00:00.000000 | md5('1001')                 | 2019-01-01 00:00:00.000000    | md5('1001')                 | 2019-01-04 00:00:00.000000    | md5('1001')                   | 2019-01-06 00:00:00.000000      |
      | md5('1001') | 2019-01-14 00:00:00.000000 | md5('1001')                 | 2019-01-12 00:00:00.000000    | md5('1001')                 | 2019-01-08 00:00:00.000000    | md5('1001')                   | 2019-01-10 00:00:00.000000      |
      | md5('1001') | 2019-01-21 00:00:00.000000 | md5('1001')                 | 2019-01-16 00:00:00.000000    | md5('1001')                 | 2019-01-19 00:00:00.000000    | md5('1001')                   | 2019-01-20 00:00:00.000000      |


  @fixture.pit
  Scenario: Load into a pit table where the AS IS table is already established but the final pit table will deal with NULL Values as ghosts
    Given the PIT table does not exist
    And the raw vault contains empty tables
      | HUBS         | LINKS | SATS                       | T_LINKS | EFF_SATS | PITS         |
      | HUB_CUSTOMER |       | SAT_CUSTOMER_DETAILS_APP   |         |          | PIT_CUSTOMER |
      |              |       | SAT_CUSTOMER_DETAILS_WEB   |         |          |              |
      |              |       | SAT_CUSTOMER_DETAILS_PHONE |         |          |              |
    And the RAW_STAGE_APP table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | 2019-01-01 00:00:00.000000 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Liverpool         | 2019-01-12 00:00:00.000000 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Glasgow           | 2019-01-15 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | 2019-01-01 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Phoenix           | 2019-01-08 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | San Diego         | 2019-01-20 00:00:00.000000 | App    |
    And I create the STG_CUSTOMER_APP stage
    And the RAW_STAGE_WEB table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | London            | 2019-01-04 00:00:00.000000 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Birmingham        | 2019-01-08 00:00:00.000000 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Dublin            | 2019-01-19 00:00:00.000000 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Las Vegas         | 2019-01-19 00:00:00.000000 | WEB    |
    And I create the STG_CUSTOMER_WEB stage
    And the RAW_STAGE_PHONE table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | 2019-01-05 00:00:00.000000 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Manchester        | 2019-01-06 00:00:00.000000 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Paris             | 2019-01-20 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | 2019-01-03 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Austin            | 2019-01-07 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Fort Worth        | 2019-01-15 00:00:00.000000 | Phone  |
    And I create the STG_CUSTOMER_PHONE stage
    And the AS_OF_DATE table contains data
      | AS_OF_DATE                 |
      | 2019-01-07 00:00:00.000000 |
      | 2019-01-14 00:00:00.000000 |
      | 2019-01-21 00:00:00.000000 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the SAT_CUSTOMER_DETAILS_APP table should contain expected data
      | CUSTOMER_PK | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | HASHDIFF                                      | EFFECTIVE_FROM             | LOAD_DATE                  | SOURCE |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | md5('PORTSMOUTH\|\|ALICE\|\|17-214-233-1214') | 2019-01-01 00:00:00.000000 | 2019-01-01 00:00:00.000000 | App    |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Liverpool         | md5('LIVERPOOL\|\|ALICE\|\|17-214-233-1214')  | 2019-01-12 00:00:00.000000 | 2019-01-12 00:00:00.000000 | App    |
      | md5('1001') | Alice         | 17-214-233-1214 | 1997-04-24   | Glasgow           | md5('GLASGOW\|\|ALICE\|\|17-214-233-1214')    | 2019-01-15 00:00:00.000000 | 2019-01-15 00:00:00.000000 | App    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | md5('NEW YORK\|\|BOB\|\|17-214-233-1215')     | 2019-01-01 00:00:00.000000 | 2019-01-01 00:00:00.000000 | App    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | Phoenix           | md5('PHOENIX\|\|BOB\|\|17-214-233-1215')      | 2019-01-08 00:00:00.000000 | 2019-01-08 00:00:00.000000 | App    |
      | md5('1002') | Bob           | 17-214-233-1215 | 2006-04-17   | San Diego         | md5('SAN DIEGO\|\|BOB\|\|17-214-233-1215')    | 2019-01-20 00:00:00.000000 | 2019-01-20 00:00:00.000000 | App    |
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_APP_PK | SAT_CUSTOMER_DETAILS_APP_LDTS | SAT_CUSTOMER_DETAILS_WEB_PK | SAT_CUSTOMER_DETAILS_WEB_LDTS | SAT_CUSTOMER_DETAILS_PHONE_PK | SAT_CUSTOMER_DETAILS_PHONE_LDTS |
      | md5('1001') | 2019-01-07 00:00:00.000000 | md5('1001')                 | 2019-01-01 00:00:00.000000    | md5('1001')                 | 2019-01-04 00:00:00.000000    | md5('1001')                   | 2019-01-06  00:00:00.000000     |
      | md5('1001') | 2019-01-14 00:00:00.000000 | md5('1001')                 | 2019-01-12 00:00:00.000000    | md5('1001')                 | 2019-01-08 00:00:00.000000    | md5('1001')                   | 2019-01-06  00:00:00.000000     |
      | md5('1001') | 2019-01-21 00:00:00.000000 | md5('1001')                 | 2019-01-15 00:00:00.000000    | md5('1001')                 | 2019-01-19 00:00:00.000000    | md5('1001')                   | 2019-01-20  00:00:00.000000     |
      | md5('1002') | 2019-01-07 00:00:00.000000 | md5('1002')                 | 2019-01-01 00:00:00.000000    | 0000000000000000            | 0000-01-01 00:00:00.000000    | md5('1002')                   | 2019-01-07  00:00:00.000000     |
      | md5('1002') | 2019-01-14 00:00:00.000000 | md5('1002')                 | 2019-01-08 00:00:00.000000    | 0000000000000000            | 0000-01-01 00:00:00.000000    | md5('1002')                   | 2019-01-07  00:00:00.000000     |
      | md5('1002') | 2019-01-21 00:00:00.000000 | md5('1002')                 | 2019-01-20 00:00:00.000000    | md5('1002')                 | 2019-01-19 00:00:00.000000    | md5('1002')                   | 2019-01-15  00:00:00.000000     |


  @fixture.pit
  Scenario: Load into a pit table where the AS IS table is already established and the AS IS table has increments of 30 mins
    Given the PIT table does not exist
    And the raw vault contains empty tables
      | HUBS         | LINKS | SATS                       | T_LINKS | EFF_SATS | PITS         |
      | HUB_CUSTOMER |       | SAT_CUSTOMER_DETAILS_APP   |         |          | PIT_CUSTOMER |
      |              |       | SAT_CUSTOMER_DETAILS_WEB   |         |          |              |
      |              |       | SAT_CUSTOMER_DETAILS_PHONE |         |          |              |
    And the RAW_STAGE_APP table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | 2019-01-01 10:22:00 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Liverpool         | 2019-01-01 10:44:00 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Glasgow           | 2019-01-01 11:12:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | 2019-01-01 10:16:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Phoenix           | 2019-01-01 10:52:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | San Diego         | 2019-01-01 11:01:00 | App    |
    And I create the STG_CUSTOMER_APP stage
    And the RAW_STAGE_WEB table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | London            | 2019-01-01 10:16:00 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Birmingham        | 2019-01-01 10:56:00 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Dublin            | 2019-01-01 11:22:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Dallas            | 2019-01-01 10:07:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | El Paso           | 2019-01-01 10:49:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Las Vegas         | 2019-01-01 11:28:00 | WEB    |
    And I create the STG_CUSTOMER_WEB stage
    And the RAW_STAGE_PHONE table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | 2019-01-01 10:09:00 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Manchester        | 2019-01-01 10:38:00 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Paris             | 2019-01-01 11:08:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | 2019-01-01 10:22:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Austin            | 2019-01-01 10:38:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Fort Worth        | 2019-01-01 11:17:00 | Phone  |
    And I create the STG_CUSTOMER_PHONE stage
    And the AS_OF_DATE table contains data
      | AS_OF_DATE          |
      | 2019-01-01 10:30:00 |
      | 2019-01-01 11:00:00 |
      | 2019-01-01 11:30:00 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE          | SAT_CUSTOMER_DETAILS_APP_PK | SAT_CUSTOMER_DETAILS_APP_LDTS | SAT_CUSTOMER_DETAILS_WEB_PK | SAT_CUSTOMER_DETAILS_WEB_LDTS | SAT_CUSTOMER_DETAILS_PHONE_PK | SAT_CUSTOMER_DETAILS_PHONE_LDTS |
      | md5('1001') | 2019-01-01 10:30:00 | md5('1001')                 | 2019-01-01 10:22:00           | md5('1001')                 | 2019-01-01 10:16:00           | md5('1001')                   | 2019-01-01 10:09:00             |
      | md5('1001') | 2019-01-01 11:00:00 | md5('1001')                 | 2019-01-01 10:44:00           | md5('1001')                 | 2019-01-01 10:56:00           | md5('1001')                   | 2019-01-01 10:38:00             |
      | md5('1001') | 2019-01-01 11:30:00 | md5('1001')                 | 2019-01-01 11:12:00           | md5('1001')                 | 2019-01-01 11:22:00           | md5('1001')                   | 2019-01-01 11:08:00             |
      | md5('1002') | 2019-01-01 10:30:00 | md5('1002')                 | 2019-01-01 10:16:00           | md5('1002')                 | 2019-01-01 10:07:00           | md5('1002')                   | 2019-01-01 10:22:00             |
      | md5('1002') | 2019-01-01 11:00:00 | md5('1002')                 | 2019-01-01 10:52:00           | md5('1002')                 | 2019-01-01 10:49:00           | md5('1002')                   | 2019-01-01 10:38:00             |
      | md5('1002') | 2019-01-01 11:30:00 | md5('1002')                 | 2019-01-01 11:01:00           | md5('1002')                 | 2019-01-01 11:28:00           | md5('1002')                   | 2019-01-01 11:17:00             |

  @fixture.pit
  Scenario: Load into a pit table where the AS IS table dates are before the satallites have received any entry's
    Given the PIT table does not exist
    And the raw vault contains empty tables
      | HUBS         | LINKS | SATS                       | T_LINKS | EFF_SATS | PITS         |
      | HUB_CUSTOMER |       | SAT_CUSTOMER_DETAILS_APP   |         |          | PIT_CUSTOMER |
      |              |       | SAT_CUSTOMER_DETAILS_WEB   |         |          |              |
      |              |       | SAT_CUSTOMER_DETAILS_PHONE |         |          |              |
    And the RAW_STAGE_APP table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | 2019-01-01 10:22:00 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Liverpool         | 2019-01-01 10:44:00 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Glasgow           | 2019-01-01 11:12:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | 2019-01-01 10:16:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Phoenix           | 2019-01-01 10:52:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | San Diego         | 2019-01-01 11:01:00 | App    |
    And I create the STG_CUSTOMER_APP stage
    And the RAW_STAGE_WEB table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | London            | 2019-01-01 10:16:00 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Birmingham        | 2019-01-01 10:56:00 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Dublin            | 2019-01-01 11:22:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Dallas            | 2019-01-01 10:07:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | El Paso           | 2019-01-01 10:49:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Las Vegas         | 2019-01-01 11:28:00 | WEB    |
    And I create the STG_CUSTOMER_WEB stage
    And the RAW_STAGE_PHONE table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | 2019-01-01 10:09:00 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Manchester        | 2019-01-01 10:38:00 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Paris             | 2019-01-01 11:08:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | 2019-01-01 10:22:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Austin            | 2019-01-01 10:38:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Fort Worth        | 2019-01-01 11:17:00 | Phone  |
    And I create the STG_CUSTOMER_PHONE stage
    And the AS_OF_DATE table contains data
      | AS_OF_DATE          |
      | 2018-01-01 10:30:00 |
      | 2018-01-01 11:00:00 |
      | 2018-01-01 11:30:00 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE          | SAT_CUSTOMER_DETAILS_APP_PK | SAT_CUSTOMER_DETAILS_APP_LDTS | SAT_CUSTOMER_DETAILS_WEB_PK | SAT_CUSTOMER_DETAILS_WEB_LDTS | SAT_CUSTOMER_DETAILS_PHONE_PK | SAT_CUSTOMER_DETAILS_PHONE_LDTS |
      | md5('1001') | 2018-01-01 10:30:00 | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000              | 0000-01-01 00:00:00.000000      |
      | md5('1001') | 2018-01-01 11:00:00 | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000              | 0000-01-01 00:00:00.000000      |
      | md5('1001') | 2018-01-01 11:30:00 | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000              | 0000-01-01 00:00:00.000000      |
      | md5('1002') | 2018-01-01 10:30:00 | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000              | 0000-01-01 00:00:00.000000      |
      | md5('1002') | 2018-01-01 11:00:00 | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000              | 0000-01-01 00:00:00.000000      |
      | md5('1002') | 2018-01-01 11:30:00 | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000            | 0000-01-01 00:00:00.000000    | 0000000000000000              | 0000-01-01 00:00:00.000000      |


  @fixture.pit
  Scenario: Load into a pit table where the AS IS table dates are after the most recent satallite entry's
    Given the PIT table does not exist
    And the raw vault contains empty tables
      | HUBS         | LINKS | SATS                       | T_LINKS | EFF_SATS | PITS         |
      | HUB_CUSTOMER |       | SAT_CUSTOMER_DETAILS_APP   |         |          | PIT_CUSTOMER |
      |              |       | SAT_CUSTOMER_DETAILS_WEB   |         |          |              |
      |              |       | SAT_CUSTOMER_DETAILS_PHONE |         |          |              |
    And the RAW_STAGE_APP table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | 2019-01-01 10:22:00 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Liverpool         | 2019-01-01 10:44:00 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Glasgow           | 2019-01-01 11:12:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | 2019-01-01 10:16:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Phoenix           | 2019-01-01 10:52:00 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | San Diego         | 2019-01-01 11:01:00 | App    |
    And I create the STG_CUSTOMER_APP stage
    And the RAW_STAGE_WEB table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | London            | 2019-01-01 10:16:00 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Birmingham        | 2019-01-01 10:56:00 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Dublin            | 2019-01-01 11:22:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Dallas            | 2019-01-01 10:07:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | El Paso           | 2019-01-01 10:49:00 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Las Vegas         | 2019-01-01 11:28:00 | WEB    |
    And I create the STG_CUSTOMER_WEB stage
    And the RAW_STAGE_PHONE table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE           | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | 2019-01-01 10:09:00 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Manchester        | 2019-01-01 10:38:00 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Paris             | 2019-01-01 11:08:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | 2019-01-01 10:22:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Austin            | 2019-01-01 10:38:00 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Fort Worth        | 2019-01-01 11:17:00 | Phone  |
    And I create the STG_CUSTOMER_PHONE stage
    And the AS_OF_DATE table contains data
      | AS_OF_DATE          |
      | 2019-01-02 10:30:00 |
      | 2019-01-02 11:00:00 |
      | 2019-01-02 11:30:00 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE          | SAT_CUSTOMER_DETAILS_APP_PK | SAT_CUSTOMER_DETAILS_APP_LDTS | SAT_CUSTOMER_DETAILS_WEB_PK | SAT_CUSTOMER_DETAILS_WEB_LDTS | SAT_CUSTOMER_DETAILS_PHONE_PK | SAT_CUSTOMER_DETAILS_PHONE_LDTS |
      | md5('1001') | 2019-01-02 10:30:00 | md5('1001')                 | 2019-01-01 11:12:00           | md5('1001')                 | 2019-01-01 11:22:00           | md5('1001')                   | 2019-01-01 11:08:00             |
      | md5('1001') | 2019-01-02 11:00:00 | md5('1001')                 | 2019-01-01 11:12:00           | md5('1001')                 | 2019-01-01 11:22:00           | md5('1001')                   | 2019-01-01 11:08:00             |
      | md5('1001') | 2019-01-02 11:30:00 | md5('1001')                 | 2019-01-01 11:12:00           | md5('1001')                 | 2019-01-01 11:22:00           | md5('1001')                   | 2019-01-01 11:08:00             |
      | md5('1002') | 2019-01-02 10:30:00 | md5('1002')                 | 2019-01-01 11:01:00           | md5('1002')                 | 2019-01-01 11:28:00           | md5('1002')                   | 2019-01-01 11:17:00             |
      | md5('1002') | 2019-01-02 11:00:00 | md5('1002')                 | 2019-01-01 11:01:00           | md5('1002')                 | 2019-01-01 11:28:00           | md5('1002')                   | 2019-01-01 11:17:00             |
      | md5('1002') | 2019-01-02 11:30:00 | md5('1002')                 | 2019-01-01 11:01:00           | md5('1002')                 | 2019-01-01 11:28:00           | md5('1002')                   | 2019-01-01 11:17:00             |

  @fixture.pit
  Scenario: Load into a pit table where the pit table is already populated
    Given the PIT_CUSTOMER table does not exist
    And the raw vault contains empty tables
      | HUBS         | LINKS | SATS                       | T_LINKS | EFF_SATS | PITS |
      | HUB_CUSTOMER |       | SAT_CUSTOMER_DETAILS_APP   |         |          |      |
      |              |       | SAT_CUSTOMER_DETAILS_WEB   |         |          |      |
      |              |       | SAT_CUSTOMER_DETAILS_PHONE |         |          |      |
    And the RAW_STAGE_APP table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | 2019-01-01 00:00:00.000000 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Liverpool         | 2019-01-12 00:00:00.000000 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Glasgow           | 2019-01-16 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | 2019-01-01 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Phoenix           | 2019-01-08 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | San Diego         | 2019-01-20 00:00:00.000000 | App    |
    And I create the STG_CUSTOMER_APP stage
    And the RAW_STAGE_WEB table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | London            | 2019-01-04 00:00:00.000000 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Birmingham        | 2019-01-08 00:00:00.000000 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Dublin            | 2019-01-19 00:00:00.000000 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Dallas            | 2019-01-06 00:00:00.000000 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | El Paso           | 2019-01-09 00:00:00.000000 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Las Vegas         | 2019-01-19 00:00:00.000000 | WEB    |
    And I create the STG_CUSTOMER_WEB stage
    And the RAW_STAGE_PHONE table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | 2019-01-06 00:00:00.000000 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Manchester        | 2019-01-10 00:00:00.000000 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Paris             | 2019-01-20 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | 2019-01-03 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Austin            | 2019-01-07 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Fort Worth        | 2019-01-15 00:00:00.000000 | Phone  |
    And I create the STG_CUSTOMER_PHONE stage
    And the AS_OF_DATE table contains data
      | AS_OF_DATE                 |
      | 2019-01-07 00:00:00.000000 |
      | 2019-01-14 00:00:00.000000 |
      | 2019-01-21 00:00:00.000000 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_APP_PK | SAT_CUSTOMER_DETAILS_APP_LDTS | SAT_CUSTOMER_DETAILS_WEB_PK | SAT_CUSTOMER_DETAILS_WEB_LDTS | SAT_CUSTOMER_DETAILS_PHONE_PK | SAT_CUSTOMER_DETAILS_PHONE_LDTS |
      | md5('1002') | 2019-01-07 00:00:00.000000 | md5('1002')                 | 2019-01-01 00:00:00.000000    | md5('1002')                 | 2019-01-06 00:00:00.000000    | md5('1002')                   | 2019-01-07 00:00:00.000000      |
      | md5('1002') | 2019-01-14 00:00:00.000000 | md5('1002')                 | 2019-01-08 00:00:00.000000    | md5('1002')                 | 2019-01-09 00:00:00.000000    | md5('1002')                   | 2019-01-07 00:00:00.000000      |
      | md5('1002') | 2019-01-21 00:00:00.000000 | md5('1002')                 | 2019-01-20 00:00:00.000000    | md5('1002')                 | 2019-01-19 00:00:00.000000    | md5('1002')                   | 2019-01-15 00:00:00.000000      |
      | md5('1001') | 2019-01-07 00:00:00.000000 | md5('1001')                 | 2019-01-01 00:00:00.000000    | md5('1001')                 | 2019-01-04 00:00:00.000000    | md5('1001')                   | 2019-01-06 00:00:00.000000      |
      | md5('1001') | 2019-01-14 00:00:00.000000 | md5('1001')                 | 2019-01-12 00:00:00.000000    | md5('1001')                 | 2019-01-08 00:00:00.000000    | md5('1001')                   | 2019-01-10 00:00:00.000000      |
      | md5('1001') | 2019-01-21 00:00:00.000000 | md5('1001')                 | 2019-01-16 00:00:00.000000    | md5('1001')                 | 2019-01-19 00:00:00.000000    | md5('1001')                   | 2019-01-20 00:00:00.000000      |

  @fixture.pit
  Scenario: Load into a pit table over several cycles
    Given the PIT table does not exist
    And the RAW_STAGE_APP stage is empty
    And the RAW_STAGE_WEB stage is empty
    And the RAW_STAGE_PHONE stage is empty
    And the raw vault contains empty tables
      | HUBS         | LINKS | SATS                       | T_LINKS | EFF_SATS | PIT          |
      | HUB_CUSTOMER |       | SAT_CUSTOMER_DETAILS_APP   |         |          | PIT_CUSTOMER |
      |              |       | SAT_CUSTOMER_DETAILS_WEB   |         |          |              |
      |              |       | SAT_CUSTOMER_DETAILS_PHONE |         |          |              |
    When the RAW_STAGE_APP is loaded
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | 2019-01-01 00:00:00.000000 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Liverpool         | 2019-01-02 00:00:00.000000 | App    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Glasgow           | 2019-01-03 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | 2019-01-01 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Phoenix           | 2019-01-02 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | San Diego         | 2019-01-03 00:00:00.000000 | App    |
    And I create the STG_CUSTOMER_APP stage
    When the RAW_STAGE_WEB is loaded
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | London            | 2019-01-01 00:00:00.000000 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Birmingham        | 2019-01-02 00:00:00.000000 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Dublin            | 2019-01-03 00:00:00.000000 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Dallas            | 2019-01-01 00:00:00.000000 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | El Paso           | 2019-01-02 00:00:00.000000 | WEB    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Las Vegas         | 2019-01-03 00:00:00.000000 | WEB    |
    And I create the STG_CUSTOMER_WEB stage
    When the RAW_STAGE_PHONE is loaded
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | 2019-01-01 00:00:00.000000 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Manchester        | 2019-01-02 00:00:00.000000 | Phone  |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Paris             | 2019-01-03 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | 2019-01-01 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Austin            | 2019-01-02 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Fort Worth        | 2019-01-03 00:00:00.000000 | Phone  |
    And I create the STG_CUSTOMER_PHONE stage
    When the AS_OF_DATE is loaded
      | AS_OF_DATE                 |
      | 2019-01-01 00:00:00.000000 |
      | 2019-01-02 00:00:00.000000 |
      | 2019-01-03 00:00:00.000000 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_APP_PK | SAT_CUSTOMER_DETAILS_APP_LDTS | SAT_CUSTOMER_DETAILS_WEB_PK | SAT_CUSTOMER_DETAILS_WEB_LDTS | SAT_CUSTOMER_DETAILS_PHONE_PK | SAT_CUSTOMER_DETAILS_PHONE_LDTS |
      | md5('1002') | 2019-01-01 00:00:00.000000 | md5('1002')                 | 2019-01-01 00:00:00.000000    | md5('1002')                 | 2019-01-01 00:00:00.000000    | md5('1002')                   | 2019-01-01 00:00:00.000000      |
      | md5('1002') | 2019-01-02 00:00:00.000000 | md5('1002')                 | 2019-01-02 00:00:00.000000    | md5('1002')                 | 2019-01-02 00:00:00.000000    | md5('1002')                   | 2019-01-02 00:00:00.000000      |
      | md5('1002') | 2019-01-03 00:00:00.000000 | md5('1002')                 | 2019-01-03 00:00:00.000000    | md5('1002')                 | 2019-01-03 00:00:00.000000    | md5('1002')                   | 2019-01-03 00:00:00.000000      |
      | md5('1001') | 2019-01-01 00:00:00.000000 | md5('1001')                 | 2019-01-01 00:00:00.000000    | md5('1001')                 | 2019-01-01 00:00:00.000000    | md5('1001')                   | 2019-01-01 00:00:00.000000      |
      | md5('1001') | 2019-01-02 00:00:00.000000 | md5('1001')                 | 2019-01-02 00:00:00.000000    | md5('1001')                 | 2019-01-02 00:00:00.000000    | md5('1001')                   | 2019-01-02 00:00:00.000000      |
      | md5('1001') | 2019-01-03 00:00:00.000000 | md5('1001')                 | 2019-01-03 00:00:00.000000    | md5('1001')                 | 2019-01-03 00:00:00.000000    | md5('1001')                   | 2019-01-03 00:00:00.000000      |
    When the RAW_STAGE_APP is loaded
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Portsmouth        | 2019-01-01 00:00:00.000000 | App    |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | New York          | 2019-01-01 00:00:00.000000 | App    |
    And I create the STG_CUSTOMER_APP stage
    When the RAW_STAGE_WEB is loaded
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | London            | 2019-01-01 00:00:00.000000 | WEB    |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Birmingham        | 2019-01-02 00:00:00.000000 | WEB    |
    And I create the STG_CUSTOMER_WEB stage
    When the RAW_STAGE_PHONE is loaded
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_PHONE  | CUSTOMER_DOB | CUSTOMER_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 17-214-233-1214 | 1997-04-24   | Swansea           | 2019-01-01 00:00:00.000000 | Phone  |
      | 1002        | Bob           | 17-214-233-1215 | 2006-04-17   | Washington        | 2019-01-01 00:00:00.000000 | Phone  |
    And I create the STG_CUSTOMER_PHONE stage
    When the AS_OF_DATE is loaded
      | AS_OF_DATE                 |
      | 2019-01-02 00:00:00.000000 |
      | 2019-01-03 00:00:00.000000 |
      | 2019-01-04 00:00:00.000000 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | SAT_CUSTOMER_DETAILS_APP_PK | SAT_CUSTOMER_DETAILS_APP_LDTS | SAT_CUSTOMER_DETAILS_WEB_PK | SAT_CUSTOMER_DETAILS_WEB_LDTS | SAT_CUSTOMER_DETAILS_PHONE_PK | SAT_CUSTOMER_DETAILS_PHONE_LDTS |
      | md5('1002') | 2019-01-02 00:00:00.000000 | md5('1002')                 | 2019-01-02 00:00:00.000000    | md5('1002')                 | 2019-01-02 00:00:00.000000    | md5('1002')                   | 2019-01-02 00:00:00.000000      |
      | md5('1002') | 2019-01-03 00:00:00.000000 | md5('1002')                 | 2019-01-03 00:00:00.000000    | md5('1002')                 | 2019-01-03 00:00:00.000000    | md5('1002')                   | 2019-01-03 00:00:00.000000      |
      | md5('1002') | 2019-01-04 00:00:00.000000 | md5('1002')                 | 2019-01-04 00:00:00.000000    | md5('1002')                 | 2019-01-04 00:00:00.000000    | md5('1002')                   | 2019-01-04 00:00:00.000000      |
      | md5('1001') | 2019-01-02 00:00:00.000000 | md5('1001')                 | 2019-01-02 00:00:00.000000    | md5('1001')                 | 2019-01-02 00:00:00.000000    | md5('1001')                   | 2019-01-02 00:00:00.000000      |
      | md5('1001') | 2019-01-03 00:00:00.000000 | md5('1001')                 | 2019-01-03 00:00:00.000000    | md5('1001')                 | 2019-01-03 00:00:00.000000    | md5('1001')                   | 2019-01-03 00:00:00.000000      |
      | md5('1001') | 2019-01-04 00:00:00.000000 | md5('1001')                 | 2019-01-04 00:00:00.000000    | md5('1001')                 | 2019-01-04 00:00:00.000000    | md5('1001')                   | 2019-01-04 00:00:00.000000      |

  @fixture.pit
  Scenario:
    Given the PIT table does not exist
    And the raw vault contains empty tables
      | HUBS         | LINKS | SATS                 | T_LINKS | EFF_SATS | PIT          |
      | HUB_CUSTOMER |       | SAT_CUSTOMER_DETAILS |         |          | PIT_CUSTOMER |
      |              |       | SAT_CUSTOMER_TRAVEL  |         |          |              |
      |              |       | SAT_CUSTOMER_PHONE   |         |          |              |
    And the RAW_STAGE_DETAILS table contains data
      | CUSTOMER_ID | CUSTOMER_NAME | CUSTOMER_ADDRESS                 | CUSTOMER_DOB | LOAD_DATE                  | SOURCE |
      | 1001        | Alice         | 1 Forrest road Hampshire FK3 4OC | 1997-04-24   | 2019-01-01 00:00:00.000000 | App    |
      | 1001        | Alice         | 1 Forrest road Hampshire FK3 4OC | 1997-04-24   | 2019-01-12 00:00:00.000000 | App    |
      | 1001        | Alice         | 1 Forrest road Hampshire FK3 4OC | 1997-04-24   | 2019-01-16 00:00:00.000000 | App    |
      | 1002        | Bob           | 1 Forrest road Hampshire FK3 4OC | 2006-04-17   | 2019-01-01 00:00:00.000000 | App    |
      | 1002        | Bob           | 1 Forrest road Hampshire FK3 4OC | 2006-04-17   | 2019-01-08 00:00:00.000000 | App    |
      | 1002        | Bob           | 1 Forrest road Hampshire FK3 4OC | 2006-04-17   | 2019-01-20 00:00:00.000000 | App    |
    And I create the STG_CUSTOMER_DETAILS stage
    And the RAW_STAGE_TRAVEL table contains data
      | CUSTOMER_ID | TRAVEL_METHOD | CUSTOMER_START_LOCATION | CUSTOMER_END_LOCATION | LOAD_DATE                  | SOURCE |
      | 1001        | TRAIN         | Portsmouth              | London                | 2019-01-04 00:00:00.000000 | WEB    |
      | 1001        | CAR RENTAL    | London                  | Birmingham            | 2019-01-08 00:00:00.000000 | WEB    |
      | 1001        | PLANE         | Birmingham              | Dublin                | 2019-01-19 00:00:00.000000 | WEB    |
      | 1002        | PLANE         | New York                | Dallas                | 2019-01-06 00:00:00.000000 | WEB    |
      | 1002        | PLANE         | Dallas                  | El Paso               | 2019-01-09 00:00:00.000000 | WEB    |
      | 1002        | PLANE         | El Paso                 | Las Vegas             | 2019-01-19 00:00:00.000000 | WEB    |
    And I create the STG_CUSTOMER_TRAVEL stage
    And the RAW_STAGE_CONTACTS table contains data
      | CUSTOMER_ID | CUSTOMER_EMAIL               | CUSTOMER_PHONE  | CUSTOMER_FAX                  | METHOD_OF_CONTACT | LOAD_DATE                  | SOURCE |
      | 1001        | Alice.smith@book-selling.com | 17-214-233-1214 | 13235551234@booke-selling.com | EMAIL             | 2019-01-06 00:00:00.000000 | Phone  |
      | 1001        | Alice.smith@book-selling.com | 17-214-233-1214 | 13235551234@booke-selling.com | TEXT              | 2019-01-10 00:00:00.000000 | Phone  |
      | 1001        | Alice.smith@book-selling.com | 17-214-233-1214 | 13235551234@booke-selling.com | PHONE CALL        | 2019-01-20 00:00:00.000000 | Phone  |
      | 1002        | Bob.taylor@book-selling.com  | 17-214-233-1215 | 13235551234@booke-selling.com | TEXT              | 2019-01-03 00:00:00.000000 | Phone  |
      | 1002        | Bob.taylor@book-selling.com  | 17-214-233-1215 | 13235551234@booke-selling.com | TEXT              | 2019-01-07 00:00:00.000000 | Phone  |
      | 1002        | Bob.taylor@book-selling.com  | 17-214-233-1215 | 13235551234@booke-selling.com | CALL              | 2019-01-15 00:00:00.000000 | Phone  |
    And I create the STG_CUSTOMER_CONTACTS stage
    And the AS_OF_DATE table contains data
      | AS_OF_DATE                 |
      | 2019-01-07 00:00:00.000000 |
      | 2019-01-14 00:00:00.000000 |
      | 2019-01-21 00:00:00.000000 |
    And I create the AS_OF_DATE stage
    When I load the vault
    Then the PIT_CUSTOMER table should contain expected data
      | CUSTOMER_PK | AS_OF_DATE                 | CUSTOMER_ADDRESS_FK                     | CUSTOMER_ADDRESS_LDTS      | LOCATION_FK       | LOCATION_LDTS              | METHOD_OF_CONTACT_PK | METHOD_OF_CONTACT_LDTS     |
      | md5('1002') | 2019-01-07 00:00:00.000000 | md5('1 Forrest road Hampshire FK3 4OC') | 2019-01-01 00:00:00.000000 | md5('London')     | 2019-01-06 00:00:00.000000 | md5('EMAIL')         | 2019-01-07 00:00:00.000000 |
      | md5('1002') | 2019-01-14 00:00:00.000000 | md5('1 Forrest road Hampshire FK3 4OC') | 2019-01-08 00:00:00.000000 | md5('Birmingham') | 2019-01-09 00:00:00.000000 | md5('TEXT')          | 2019-01-07 00:00:00.000000 |
      | md5('1002') | 2019-01-21 00:00:00.000000 | md5('1 Forrest road Hampshire FK3 4OC') | 2019-01-20 00:00:00.000000 | md5('Dublin')     | 2019-01-19 00:00:00.000000 | md5('PHONE CALL')    | 2019-01-15 00:00:00.000000 |
      | md5('1001') | 2019-01-07 00:00:00.000000 | md5('1 Forrest road Hampshire FK3 4OC') | 2019-01-01 00:00:00.000000 | md5('Dallas')     | 2019-01-04 00:00:00.000000 | md5('TEXT')          | 2019-01-06 00:00:00.000000 |
      | md5('1001') | 2019-01-14 00:00:00.000000 | md5('1 Forrest road Hampshire FK3 4OC') | 2019-01-12 00:00:00.000000 | md5('El Paso')    | 2019-01-08 00:00:00.000000 | md5('TEXT')          | 2019-01-10 00:00:00.000000 |
      | md5('1001') | 2019-01-21 00:00:00.000000 | md5('1 Forrest road Hampshire FK3 4OC') | 2019-01-16 00:00:00.000000 | md5('Las Vegas ') | 2019-01-19 00:00:00.000000 | md5('CALL')          | 2019-01-20 00:00:00.000000 |