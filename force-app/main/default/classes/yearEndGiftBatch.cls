//Code by Jessie Rymph
//December 30, 2021
//
//launch in execute anonymous by pasting in the next line without the two //
//Id batchJobId = Database.executeBatch(new yearEndGiftBatch());
//https://wp.me/p9qPLI-1q8

public class yearEndGiftBatch implements Database.Batchable<sObject>,Database.Stateful {
    //instance member to retain state across transactions
    public static Integer emailLimits;
    public Integer recordsProcessed =0;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Integer year = Date.Today().year()-1;        
        return Database.getQueryLocator([SELECT LastName, id,Gifts_Last_Year__c, (SELECT Id, CloseDate, Amount FROM Opportunities 
                                                                                  WHERE CALENDAR_YEAR(CloseDate) =:year AND IsWon = True ORDER 
                                                                                  BY CloseDate) FROM Contact WHERE npo02__OppAmountLastYear__c > 0 WITH SECURITY_ENFORCED]);          
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        //process each batch of records
        List<Contact> contactsForUpdate = new List<Contact>();
        String loopString;
        String longestString = '<table style="width:100%; border: 1px solid black;"><tr><th style="border: 1px solid black; padding: 15px;"> Date</th>   <th style="border: 1px solid black;">Amount</th></tr>';
        String dateFormatString = 'MMMM d, yyyy';
        String finalString;
        for (Contact con : scope) {
            for (Opportunity opp : con.opportunities) {
                Date d = opp.CloseDate;
                Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
                String dateString = dt.format(dateFormatString);
                String cleanAmt = String.valueOf(opp.Amount);
                
                loopString =
                    '<tr> <td style="border: 1px solid black; padding: 15px;">' + dateString +
                    '</th> <td style="border: 1px solid black; padding: 15px;"> $' + cleanAmt + '</th> </tr>';
                longestString = longestString + loopString;
            }
            finalstring = longestString + '</table>';
            con.Gifts_Last_Year__c = String.escapeSingleQuotes(finalstring);
            contactsForUpdate.add(con);
            //reset the value of longestString to the start. otherwise it's going to add everyone's gifts to the list and keep growing. 
			longestString = '<table style="width:100%; border: 1px solid black;"><tr><th style="border: 1px solid black; padding: 15px;"> Date</th>   <th style="border: 1px solid black;">Amount</th></tr>';
            recordsProcessed = recordsProcessed + 1;
             system.debug('Final String' + finalstring);
        }
        update contactsForUpdate;
    }
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        
        String subject = 'Year End Gift Batches complete';
        String body = 'records processed ' + recordsProcessed.format() + '. The batch apex processed '+ job.TotalJobItems;
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        // Now sets the below paramaters of the email object
        email.setSubject( subject );
        // Here I am accessing current user email id to whom we are sending email
        email.setToAddresses( new String[] {UserInfo.getUserEmail()} );
        email.setPlainTextBody( body );
        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
        system.debug('records processed: ' + recordsProcessed);
        emailLimits = Limits.getEmailInvocations();
        system.debug ('emaillimits:' + emailLimits);
        if (r[0].success) {
            System.debug('The email was sent successfully to ' + UserInfo.getUserEmail());
        } else {
            System.debug('The email failed to send: '+ r[0].errors[0].message);
            FeedItem post = new FeedItem();
            post.ParentId = UserInfo.getUserId(); 
            post.Body = body;
            List<FeedItem> postList= new List<FeedItem>();
            postList.add(post);
            Insert postList;
        }  
    }
    
    
}