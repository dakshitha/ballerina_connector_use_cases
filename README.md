# ballerina_connector_use_cases

This repo contains the Ballerina code for the implementation of automating a donation submission process using Salesforce and Twilio. 

In this use case, the end-user submits a donation via a front-end application, which results in New 'Account' and ‘Opportunity’ records created dynamically in Salesforce. SMSes will be sent to the donor on ‘Opportunity’ creation (acknowledging their donation submission) and when the ‘Opportunity’ status is changed to 'Closed Won' (thanking them for their donation and communicating that the donation has been successfully processed). This is obviously not how online payments are processed in the real world. But in the absence of a payment gateway to work with, we think this hypothetical scenario would serve the purpose of demonstrating the capabilities of the Salesforce and Twilio connectors.

 There will be 2 workflows: 

- When the user submits the donation. 
- When the donation has been processed. 

So let’s walk through the first workflow, which is triggered when the donor hits the submit button, and an API call takes place.

- A new ‘Account’ and  ‘Opportunity’ must be created in Salesforce with the details passed in the payload. 
- In the next step, invoke the Twilio API to send an SMS. We can retrieve and insert first name, last name and the donation amount from the API payload to the text message that will be sent to the user :
“<First Name> <Last Name>, we have received your donation of $<Donation Amount> . We will notify you when it has been successfully processed. Thank you for your generous contribution!”

After some time, when the opportunity is updated in Salesforce after processing the donation, the 2nd workflow will get activated. 

- Once an opportunity is updated we retrieve several select fields from that opportunity record. 
- Then we perform a conditional check here to check whether that stage has been ‘Closed Won’.  
- If it’s ‘Closed Won’, we retrieve the account record in Salesforce that is associated with that closed deal in order to obtain user information and message the user.
- Next, use the name of the donor, the donation amount, date and telephone number to send the user a personalized text message (via the Twilio API) thanking the recipient/donor with the following message: 
“<First Name> <Last Name> your donation of $<Donation Amount> has been successfully processed Thank you again for your contribution!”.


## Prerequisites

- [Ballerina Distribution](https://ballerina.io/learn/getting-started/)
- A Text Editor or an IDE 
> **Tip**: For a better development experience, install one of the following Ballerina IDE plugins:  
[VSCode](https://marketplace.visualstudio.com/items?itemName=ballerina.ballerina), 
[IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina)
- [Salesforce Connector](https://github.com/ballerina-platform/module-ballerinax-sfdc), 
[Twilio Connector](https://github.com/ballerina-platform/module-ballerinax-twilio) will be downloaded from 
`Ballerina Central` when running the Ballerina file.

### Before you begin

Let's first see how to add the Salesforce and Twilio configurations to the application.

#### Setup Salesforce configurations
Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 
Obtain the following parameters:

* Base URL (Endpoint)
* Client Id
* Client Secret
* Access Token
* Refresh Token
* Refresh URL

For more information on obtaining OAuth2 credentials, visit 
[Salesforce help documentation](https://help.salesforce.com/articleView?id=remoteaccess_authenticate_overview.htm) 
or follow the 
[Setup tutorial](https://medium.com/@bpmmendis94/obtain-access-refresh-tokens-from-salesforce-rest-api-a324fe4ccd9b).

Also, keep a note of your Salesforce username, password and the security token that will be needed for initializing the listener. 

For more information on the secret token, please visit [Reset Your Security Token](https://help.salesforce.com/articleView?id=user_security_token.htm&type=5).

#### Create push topic in Salesforce developer console

The Salesforce trigger requires topics to be created for each event. We need to configure two topics as we listen on 
both Opportunity and Quote entities.

1. From the Salesforce UI, select developer console. Go to debug > Open Execute Anonymous Window. 
2. Paste following apex code to create 'OpportunityUpdate' topic
```apex
PushTopic pushTopic = new PushTopic();
pushTopic.Name = 'OpportunityUpdate';
pushTopic.Query = 'SELECT Id, Name, AccountId, StageName, Amount FROM Opportunity';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationUpdate = true;
pushTopic.NotifyForFields = 'Referenced';
insert pushTopic;
```
3. Execute another window and paste following to create 'QuoteUpdate' topic
```apex
PushTopic pushTopic = new PushTopic();
pushTopic.Name = 'QuoteUpdate';
pushTopic.Query = 'SELECT Id, Name, AccountId, OpportunityId, Status,GrandTotal  FROM Quote';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationUpdate = true;
pushTopic.NotifyForFields = 'Referenced';
insert pushTopic;
```
4. Once the creation is done, specify the topic name in each event listener service config.

#### Setup NetSuite configurations
Create a [NetSuite](https://www.netsuite.com/portal/home.shtml) account and integration record to obtain the following 
parameters:

* Client ID
* Client Secret
* Access Token
* Refresh Token
* Refresh Token URL

For more information on obtaining the above parameters, follow the 
[setup tutorial](https://medium.com/@chamilelle/setup-rest-web-service-and-oauth-2-0-in-your-netsuite-account-c4243240bc3f).

#### Setup Slack configurations
Create a new [Slack](https://api.slack.com/apps?new_granular_bot_app=1) app and obtain the access token. For more 
information on obtaining the token, follow the 
[documentation](https://github.com/ballerina-platform/module-ballerinax-slack/blob/master/src/slack/Module.md). 
Make sure you set `chat:write` and `channel:read` as scopes in your app. 

Once you obtained all configurations, Replace "" in the `ballerina.conf` file with your data.

##### ballerina.conf
```
SF_EP_URL="https://<instance-id>.salesforce.com"
SF_REDIRECT_URL="https://login.salesforce.com/"
SF_ACCESS_TOKEN="<ACCESS_TOKEN>"
SF_CLIENT_ID="<CLIENT_ID>"
SF_CLIENT_SECRET="<CLIENT_SECRET>"
SF_REFRESH_TOKEN="<REFRESH_TOKEN>"
SF_REFRESH_URL="https://login.salesforce.com/services/oauth2/token"

SF_USERNAME="<SF_USERNAME>"
SF_PASSWORD="<SF_PASSWORD + SECURITY_TOKEN>"

NS_BASE_URL="https://<instance-id>.suitetalk.api.netsuite.com"
NS_ACCESS_TOKEN="<ACCESS_TOKEN>"
NS_REFRESH_URL="https://<instance-id>.suitetalk.api.netsuite.com/services/rest/auth/oauth2/v1/token"
NS_REFRESH_TOKEN="<REFRESH_TOKEN>"
NS_CLIENT_ID="<CLIENT_ID>"
NS_CLIENT_SECRET="<CLIENT_SECRET>"

SLACK_ACCESS_TOKEN="<ACCESS_TOKEN>"
```


## Execute the integration

Go to root of the project and run following cmd.
`$ ballerina run workflow`

Successful listener startup will print following in the console.
```
>>>>
[2020-06-25 15:57:07.114] Success:[/meta/handshake]
{ext={replay=true, payload.format=true}, minimumVersion=1.0, clientId=6zp60zass9ub6xxpjc19g9e7mzj, supportedConnectionTypes=[Ljava.lang.Object;@17744dc, channel=/meta/handshake, id=1, version=1.0, successful=true}
<<<<
Subscribed: Subscription [/topic/OpportunityUpdate:-2]
```
To trigger the opportunity event listener, As the first step, you need to create an sales account called `TestWorkFlow` 
in Salesforce. Then create an opportunity for the account and set its stage as closed won. As soon as you change the 
stage event listener will get triggered with following output.
```
<<<<
Opportunity Stage : Closed Won
Account ID : 0012w00000DuVnyAAF
Account Name : TestWorkFlow
New customer is created: customer id = 41537
>>>>
```

To execute the second workflow, quote update event should be triggered. So go to the opportunity and create a quote. 
The change the stage to approved state. As soon as you change the stage, quote event listener will get triggered with 
following output.
```
2020-06-25 19:54:31,153 INFO  [ballerinaguides/workflow] - Quote Status : Approved 
2020-06-25 19:54:31,539 INFO  [ballerinaguides/workflow] - Account Name : TestWorkFlow 
2020-06-25 19:54:32,765 INFO  [ballerinaguides/workflow] - Retrieved customer id : 41537 
2020-06-25 19:54:40,178 INFO  [ballerinaguides/workflow] - The invoice has created: id = 519194 
```


-----------------------------------------------

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
 
  `ballerina add use_case_3`
   Or instead of creating a module, clone this repository in to the connector_use_cases project folder you just created. 
 
- Add the contents in ballerina.conf.copy file to your ballerina.conf file. Make sure to edit the conf file to add the relevant tokens and URLs obtained from Salesforce and Twilio. ballerina.conf.copy is merely an edited copy of my ballerina.conf file to be used for reference. 

- Run the project with the following command:

`ballerina run use_case_3`

- To activate the first workflow (i.e., create an account and opportunity in Salesforce with the given information, which is hard-coded in main.bal for the time being), run the following command in a different terminal:
`curl "http://localhost:9090/donationMgt/processDonation"`

- Check Salesforce to see the newly created Account and Opportunity under that account. The verified phone number will also receive a text message stating that the donation will be processed. 

- To activate the seconde workflow, go to Salesforce and click on the created (or any other) Opportunity and change the stage to Closed-Won. Now the verified phone number will receive a text message, which thanks and informs the user that the donation has been processed and accepted. 





