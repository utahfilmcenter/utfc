//Code by Jessie Rymph
//December 30, 2021
//Tests the Year End Gift Batch process using the YearEndtestDataFactory class
//https://wp.me/p9qPLI-1q8

@isTest
public class yearEndGiftBatchTest {
    @isTest static void positiveTest() {
        // Test data setup
        // Create contacts with opps through test utility
        Integer testNumC= 20;
        Integer testNumO = 20;
        contact[] cons = YearEndTestDataFactory.createContactsWithOpps(testNumC,testNumO);
        
        Test.startTest();
        	yearEndGiftBatch yEGB = new yearEndGiftBatch();
        	Id batchId = Database.executeBatch(yEGB);
        Test.stopTest();        
        List<Contact> contacts = new List<Contact>();

        for(Contact person : [SELECT Id, Gifts_Last_Year__c FROM Contact]) {
            if(person.Gifts_Last_Year__c.contains('Date')) {
                contacts.add(person);
            }
        }
        System.assertEquals(testNumC,contacts.size(),testNumC +' ');
       
    }
    
    @isTest static void negativeTest() {
        // Test data setup
        // Create contacts with opps through test utility
        Integer testNumC=10;
        Integer testNumO = 12;
        contact[] cons = YearEndTestDataFactory.wrongYearOpps(testNumC,testNumO);
        
        Test.startTest();
        	yearEndGiftBatch yEGB = new yearEndGiftBatch();
        	Id batchId = Database.executeBatch(yEGB);
        Test.stopTest();        
        List<Contact> contacts = new List<Contact>();

        for(Contact person : [SELECT Id, Gifts_Last_Year__c FROM Contact]) {
           
            IF(person.Gifts_Last_Year__c != null) { 
                contacts.add(person);
            }
            
        }
        System.assertEquals(0,contacts.size(),'Expected none, got' + contacts.size());

    }
    

    @IsTest
    static void testThatEmailWasSent(){
        Integer testNumC= 20;
        Integer testNumO = 20;
        contact[] cons = YearEndTestDataFactory.createContactsWithOpps(testNumC,testNumO);
        
        Test.startTest();
        yearEndGiftBatch yEGB = new yearEndGiftBatch();  	
        Id batchId = Database.executeBatch(yEGB);
        Test.stopTest();
		System.assertEquals(1,yearendGiftbatch.emaillimits);
    }
}