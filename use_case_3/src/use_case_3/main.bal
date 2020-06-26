import ballerina/http;
import thishani/sfdc;
import ballerina/io;
import ballerina/log;

listener sfdc:EventListener opportunityUpdateListener = new(opportunityListenerConfig);

service workflowTwo on opportunityUpdateListener {
    resource function onEvent(json op) {  
        //convert json string to json
        io:StringReader sr = new(op.toJsonString());
        json|error opportunity = sr.readJson();
        if (opportunity is json) {
            log:printInfo("Opportunity Stage : " + opportunity.sobject.StageName.toString());
            //check if opportunity is closed won
            if (opportunity.sobject.StageName == "Closed Won") {
                //get the account id from the opportunity
                string accountId = opportunity.sobject.AccountId.toString();
                string amount = opportunity.sobject.Amount.toString();
                log:printInfo("Account ID : " + accountId);
                //create sobject client
                sfdc:SObjectClient sobjectClient = baseClient->getSobjectClient();
                //get account
                json|sfdc:Error account = sobjectClient->getAccountById(accountId);
                if (account is json) {
                    //extract required fields from the account record
                    string accountName = account.Name.toString();
                    string toMobile = account.Phone.toString();

                    log:printInfo("Account Name : " + accountName);
                    log:printInfo("Phone Number : " + toMobile);


                    // //Twilio logic follows...
                    string msg =  accountName 
                    + ", your donation of $" 
                    + amount
                    + ". has been successfully processed. Thank you for your generous contribution!";
                    sendSMS(msg, toMobile);
                }
            }
        }
    }
}


// invoke this service - curl "http://localhost:9090/donationMgt/processDonation"

@http:ServiceConfig { basePath: "/donationMgt" }
service workflowOne on new http:Listener(9090) {

  @http:ResourceConfig {
        methods: ["GET"],
        path: "/processDonation"
        
        //Alternatively
        //methods: ["POST"]
        //path: "/donation/processDonation?phone={phoneNo}&amount={amount}"
    }
    resource function processDonation(http:Caller caller,
        http:Request req) returns error? {
    
    //   resource function processDonation(http:Caller caller,
    //    http:Request req, string phoneNo, string amount) returns error? {

           createAccountRecord();
           getAccountRecord();
           createOpportunityRecord();
           getOpportunityRecordByOpportunityId();
           string name = <string> accountRecord.Name;
           string msg =  name 
           + ", we have received your donation of $" 
           + opportunityRecord.Amount.toString() 
           + ". We will notify you when it has been successfully processed.";

           string toMobile = <string> accountRecord.Phone;

           sendSMS(msg, toMobile);
           check caller->respond("Your donation is being processed. Thank you for your generosity!");
    }
}




 