# ballerina_connector_use_cases

This repo contains the Ballerina code for the implementation of Use Case 3: Automating a Donation Submission Process Using Salesforce and Twilio.

## Prerequisites


### Salesforce configurations
- Create Salesforce account and tokens by following this tutorial - 
https://medium.com/@bpmmendis94/obtain-access-refresh-tokens-from-salesforce-rest-api-a324fe4ccd9b

- Follow this document to create the OpportunityUpdate Topic - 
https://docs.google.com/document/d/1TqYyRghbYpH-RJaVB_RWQVE_FMaoau-BtxHfESO0f7E/edit#

### Twilio configurations
- Create a Twilio account and generate the necessary tokens - https://www.twilio.com/
- Add a verified phone number to receive text messages. 
- Generate a trial number for your account to send text messages. 

### Ballerina
- Use Swan Lake Preview 1 version of Ballerina. 

`ballerina update
 ballerina dist list
 ballerina dist pull slp1`
 
 - Create a Ballerina project
 
 `ballerina new connector_use_cases`
 
 - Create a Ballerina module
 
  `ballerina add use_case_3 // new module`
   Or instead of creating a module, clone this repository in to the connector_use_cases project folder you just created. 
 
- Add the contents in ballerina.conf.copy file to your ballerina.conf file. Make sure to edit the conf file to add the relevant tokens and URLs obtained from Salesforce and Twilio. ballerina.conf.copy is merely an edited copy of my ballerina.conf file to be used for reference. 

- Run the project with the following command:

`ballerina run use_case_3`

- To activate the first workflow (i.e., create an account and opportunity in Salesforce with the given information, which is hard-coded in main.bal for the time being), run the following command in a different terminal:
`curl "http://localhost:9090/donationMgt/processDonation"`

- Check Salesforce to see the newly created Account and Opportunity under that account. The verified phone number will also receive a text message stating that the donation will be processed. 

- To activate the seconde workflow, go to Salesforce and click on the created (or any other) Opportunity and change the stage to Closed-Won. Now the verified phone number will receive a text message, which thanks and informs the user that the donation has been processed and accepted. 





