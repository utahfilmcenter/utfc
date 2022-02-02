trigger slack_UtFC_Fiscal_Sponsor_Film on UtFC_Fiscal_Sponsor_Film__c (after insert, after update, before delete) {
	if(trigger.isAfter && trigger.isInsert || trigger.isAfter && trigger.isUpdate || trigger.isBefore && trigger.isDelete) {
		slackv2__.utilities.startSubscriptionQueue(trigger.newMap, trigger.oldMap, trigger.operationType, 'UtFC_Fiscal_Sponsor_Film__c');
	}
}