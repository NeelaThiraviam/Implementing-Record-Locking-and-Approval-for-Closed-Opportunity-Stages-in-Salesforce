trigger OpportunityClosedTrigger on Opportunity (before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {

        if (TriggerControl.skipValidation) {
            return;
        }

        Id closedRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Closed Opportunity').getRecordTypeId();

        for (Opportunity opp : Trigger.new) {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
            if ((opp.StageName != oldOpp.StageName) && (oldOpp.IsClosed == true) ||
                (opp.StageName == oldOpp.StageName) && (opp.IsClosed == true)) {
                opp.addError('Unfortunately, not able to edit this record because the opportunity stage is already closed.');
            }
            if (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost') {
                opp.RecordTypeId = closedRecordTypeId;      
            }
        }
    }
}
