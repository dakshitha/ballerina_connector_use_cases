# ballerina_connector_use_cases

This repo contains the Ballerina code for the implementation of Use Case 3: Automating a Donation Submission Process Using Salesforce and Twilio.

## Prerequisites

### Ballerina
- Use Swan Lake Preview 1 version of Ballerina. 

`ballerina update
 ballerina dist list
 ballerina dist pull slp1`
 
 - Create a Ballerina project
 
 `ballerina new connector_use_cases // new project
  ballerina add use_case_3 // new module`
  
- Or instead of creating a module, clone this repository in to the connector_use_cases project folder you just created. 
 
- Add the contents in ballerina.conf.copy file to your ballerina.conf file. 

- Run the project with the following command:

`ballerina run use_case_3`

### Salesforce configurations
- Create Salesforce account and tokens by following this tutorial - 
https://medium.com/@bpmmendis94/obtain-access-refresh-tokens-from-salesforce-rest-api-a324fe4ccd9b

- Follow this document to create the OpportunityUpdate Topic - 
https://docs.google.com/document/d/1TqYyRghbYpH-RJaVB_RWQVE_FMaoau-BtxHfESO0f7E/edit#

### Twilio configurations
- Create a Twilio account and generate the necessary tokens - https://www.twilio.com/
- Add a verified phone number to receive text messages. 
- Generate a trial number for your account to send text messages. 




