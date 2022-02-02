@isTest
public class slack_tst_UtFC_Film_Event {
	@isTest 
	static void testTrigger() {
		UtFC_Film_Event__c obj0 = new UtFC_Film_Event__c(
			Program_Series__c = '10th Anniversary'
		);
		insert obj0;
	}
}