# Automating a Donation Submission Process Using Salesforce and Twilio

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

- [Ballerina Distribution](https://ballerina.io/learn/getting-started/). This sample was tested with the Swan Lake Preview 2 version of Ballerina. 

```
ballerina update
ballerina dist list
ballerina dist pull slp2 

```
 
- A Text Editor or an IDE 
> **Tip**: For a better development experience, install one of the following Ballerina IDE plugins:  
[VSCode](https://marketplace.visualstudio.com/items?itemName=ballerina.ballerina), 
[IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina)

- The [Salesforce Connector](https://github.com/ballerina-platform/module-ballerinax-sfdc) and
[Twilio Connector](https://github.com/ballerina-platform/module-ballerinax-twilio) will be downloaded from 
`Ballerina Central` when the Ballerina code is executed. See the import statements in the code. 

### Before you begin

Let's first see how to add the Salesforce and Twilio configurations to the application.

#### Salesforce configurations
Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 
Obtain the following parameters:

* Base URL (Endpoint)
* Client Id
* Client Secret
* Access Token
* Refresh Token
* Refresh URL
* Security Token

For more information on obtaining OAuth2 credentials, visit 
[Salesforce help documentation](https://help.salesforce.com/articleView?id=remoteaccess_authenticate_overview.htm) 
or follow this 
[tutorial](https://medium.com/@bpmmendis94/obtain-access-refresh-tokens-from-salesforce-rest-api-a324fe4ccd9b), which explains how to create a Salesforce account and obtain the tokens from scratch. 

Note down your Salesforce username, password and the security token that will be needed for initializing the listener. 

If you don't have the security token, go to Salesforce, at the top navigation bar go to Your name > My Settings > Personal >  Reset My Security Token. Click on "Reset Security Token". Clicking the button invalidates your existing token. After resetting your token, Salesforce will email the security token to you. 

#### Create push topic in Salesforce developer console

The Salesforce trigger requires topics to be created for each event. We need to configure a topic as we listen to changes in 'Opportunity' entities. 

1. From the Salesforce UI, select [developer console](https://help.salesforce.com/articleView?id=code_dev_console_opening.htm&type=5). Go to debug > Open Execute Anonymous Window. 
2. Paste following code to create 'OpportunityUpdate' topic
```apex
PushTopic pushTopic = new PushTopic();
pushTopic.Name = 'OpportunityUpdate';
pushTopic.Query = 'SELECT Id, Name, AccountId, StageName, Amount FROM Opportunity';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationUpdate = true;
pushTopic.NotifyForFields = 'Referenced';
insert pushTopic;
```
3. The topic name ('OpportunityUpdate') will be referred to in the config file.

#### Twilio configurations
1. Create a Twilio account and generate the necessary tokens - https://www.twilio.com/. Obtain the following parameters:
* Twilio Account SID
* Auth Token
* Twilio API Secret. 

2. Add a verified phone number to receive text messages.

3. Generate a trial number for your account to send text messages. 

Once you obtained all configurations, update the ballerina.conf file with the relevant tokens etc. 

```
#Salesforce

#The SF_EP_URL might be different for you. Check and update accordingly
SF_EP_URL="https://ap17.salesforce.com"

REDIRECT_URL="https://login.salesforce.com/"
ACCESS_TOKEN="YOUR TOKEN GOES HERE"
AUTH_CODE="YOUR AUTH CODE GOES HERE"
CLIENT_ID="YOUR SF_CLIENT_ID GOES HERE"
CLIENT_SECRET="YOUR SF CLIENT SECRET GOES HERE"
REFRESH_TOKEN="YOUR SF REFRESH TOKEN GOES HERE"
REFRESH_URL="https://login.salesforce.com/services/oauth2/token"

OPPORTUNITY_UPDATE_TOPIC="/topic/OpportunityUpdate"

#Twilio
ACCOUNT_SID="YOUR TWILIO ACCOUNT SID GOES HERE"
AUTH_TOKEN="YOUR TWILIO TOKEN GOES HERE"
X_AUTHY_API_SECRET="YOUR TWILIO API SECRET GOES HERE"

```

## Execute the integration

Go to root of the project and run following cmd.

`ballerina run sf_twilio`

- To activate the first workflow (i.e., create an account and opportunity in Salesforce with the given information, which is hard-coded in main.bal for the time being), run the following command in a different terminal:
`curl "http://localhost:9090/donationMgt/processDonation"`

- Check Salesforce to see the newly created Account and Opportunity under that account. The verified phone number will also receive a text message stating that the donation will be processed. 

- To activate the seconde workflow, go to Salesforce and click on the created (or any other) Opportunity and change the stage to Closed-Won. Now the verified phone number will receive a text message, which thanks and informs the user that the donation has been processed and accepted. 










