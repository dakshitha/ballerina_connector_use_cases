import ballerina/io;
import ballerinax/sfdc;
import ballerinax/twilio;
import ballerina/test;
import ballerina/log;

sfdc:BaseClient baseClient = new(sfConfig); 
twilio:Client twilioClient = new(twilioConfig);
string testAccountId = "";
string testOpportunityId = "";

json accountRecord = null;
json opportunityRecord = null;

function createAccountRecord() {

    accountRecord = { 
    //All field info for SF Account can be found in the link below:
    // https://developer.salesforce.com/docs/atlas.en-us.sfFieldRef.meta/sfFieldRef/salesforce_field_reference_Account.htm#!
    Name: "Donald Trump", 
    BillingCity: "Colombo 3" ,
    Phone: "+94772962552"
    };

    log:printInfo("sobjectClient -> createAccountRecord()");
    sfdc:SObjectClient sobjectClient = baseClient->getSobjectClient();
    string|sfdc:Error stringResponse = sobjectClient->createRecord("Account", accountRecord);
    //io:println("stringResponse = " + stringResponse.toString());

    if (stringResponse is string) {
        test:assertNotEquals(stringResponse, "", msg = "Found empty response!");
        testAccountId = <@untainted> stringResponse;
        io:println("create account record: testAccountId = " + testAccountId);
    } else {
        test:assertFail(msg = stringResponse.message());
    }
}

function createOpportunityRecord() {

    opportunityRecord = { 
    //All field info for SF Object can be found in the link below:
    //https://developer.salesforce.com/docs/atlas.en-us.sfFieldRef.meta/sfFieldRef/salesforce_field_reference_Opportunity.htm#!
    AccountId: testAccountId,
    Name: "Donation",
    Amount: 1000.0, 
    StageName: "New",
    CloseDate: "2020-08-01"
    };

    log:printInfo("sobjectClient -> createOpportunityRecord()");
    sfdc:SObjectClient sobjectClient = baseClient->getSobjectClient();

    string|sfdc:Error stringResponse = sobjectClient->createRecord("Opportunity", opportunityRecord);
    //io:println("stringResponse = " + stringResponse.toString());

    if (stringResponse is string) {
        test:assertNotEquals(stringResponse, "", msg = "Found empty response!");
        testOpportunityId = <@untainted> stringResponse;
        io:println("create opportunity record: testOpportunityId = " + testOpportunityId);
    } else {
         test:assertFail(msg = stringResponse.message());
    }
}


function getAccountRecord() {
    json|sfdc:Error response;
    log:printInfo("sobjectClient -> getAccountRecord()");
    string path = "/services/data/v48.0/sobjects/Account/" + testAccountId;
    sfdc:SObjectClient sobjectClient = baseClient->getSobjectClient();
    response = sobjectClient->getRecord(path);
    //io:println("stringResponse = " + response.toString());
    if response is json {
        string name =  <string> response.Name;
        string billingCity = <string> response.BillingCity;
        string phone = <string> response.Phone;

        io:println("get account record: testAccountId = " + testAccountId);
        io:println("get account record: name = " + name);
        io:println("get account record:  billingCity = " + billingCity);
        io:println("get account record:  phone = " + phone);
  
    }
    else {
        sfdc:Error err = <sfdc:Error> response;
        io:println("get account record: error = " + err.message());
    }
}

function getOpportunityRecordByOpportunityId() {
    json|sfdc:Error response;
    log:printInfo("sobjectClient -> getOpportunityRecordByOpportunityId()");
    string path = "/services/data/v48.0/sobjects/Opportunity/" + testOpportunityId;
    sfdc:SObjectClient sobjectClient = baseClient->getSobjectClient();
    response = sobjectClient->getRecord(path);

    if response is json {
        string name =  <string> response.Name;
        float amount = <float> response.Amount;
        string oppStage = <string> response.StageName;
        boolean isClosed = <boolean> response.IsClosed;
        boolean isWon = <boolean> response.IsWon;


        io:println("get account record: testOpportunityId = " + testOpportunityId);
        io:println("get opportunity record: name = " + name);
        io:println("get opportunity record:  amount = " + amount.toString());
        io:println("get opportunity record:  stage = " + oppStage);
        io:println("get opportunity record:  isClosed = " + isClosed.toString());
        io:println("get opportunity record:  isWon = " + isWon.toString());
  
    }
    else {
        sfdc:Error err = <sfdc:Error> response;
        io:println("get account record: error = " + err.message());
    }
}

function getOpportunityRecordByAccountId() {
    json|sfdc:Error response;
    log:printInfo("sobjectClient -> getOpportunityRecordbyAccountId()");
    string path = "/services/data/v48.0/query?q=select+name+from+opportunity+where+accountid=" + "'" + testAccountId + "'";

    //https://yourinstance.salesforce.com/services/data/v43.0/query?q=select+name+from+opportunity+where+accountid='<the account id>'
    sfdc:SObjectClient sobjectClient = baseClient->getSobjectClient();
    response = sobjectClient->getRecord(path);
    io:println("stringResponse = " + response.toString());
    if response is json {
        io:println(response.toString());
        test:assertNotEquals(response, (), msg = "Found null JSON response!");
        string name =  <string> response.Name;
        io:println("get opportunity record: name = " + name);
  
    }
    else {
        sfdc:Error err = <sfdc:Error> response;
        io:println("get account record: error = " + response.message());
    }
}

function updateAccountRecord() {
    log:printInfo("sobjectClient -> updateAccountRecord()");
    json account = { Name: "The Real Donald Trump", BillingCity: "Jaffna", Phone: "+94110000000" };
    sfdc:SObjectClient sobjectClient = baseClient->getSobjectClient();
    boolean|sfdc:Error response = sobjectClient->updateRecord("account", testAccountId, account);

    if (response is boolean && response == true) {
        io:println("update account record: successfully updated account record.");
    } else {
        sfdc:Error err = <sfdc:Error> response;
        io:println("update account record: error = " + err.message());
    }
}

function deleteAccountRecord() {
    log:printInfo("sobjectClient -> deleteAccountRecord()");
    sfdc:SObjectClient sobjectClient = baseClient->getSobjectClient();
    boolean|sfdc:Error response = sobjectClient->deleteRecord("Account", testAccountId);

   if (response is boolean && response == true) {
        io:println("delete account record: successfully deleted account record.");
    } else {
        sfdc:Error err = <sfdc:Error> response;
        io:println("delete account record: error = " + err.message());
    }
}

function sendSMS(string message, string toMobile) {

    string fromMobile = "+12058399270";
    var details = twilioClient->sendSms(fromMobile, toMobile, message);
    if (details is  twilio:SmsResponse) {
        // If successful, print SMS Details.
        io:println("SMS Details: ", details);
    } else {
    // If unsuccessful, print the error returned.
    io:println("Error: ", details);
    }
}

function testAccountCRUD() { 
    createAccountRecord();
    getAccountRecord();

    updateAccountRecord();
    getAccountRecord();

    deleteAccountRecord();
    getAccountRecord();

}