//PreventValidation Class
public class TriggerControl {
    public static Boolean skipValidation = false;
}

//RecordType Class
public with sharing class OppActionInvocable {
    @InvocableMethod(label='Opp Invocable Demo')
    public static void oppId(List<Id> args) {

        TriggerControl.skipValidation = true;

        //Id closedRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Closed Opportunity').getRecordTypeId();
        Id openRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Open Opportunity').getRecordTypeId();

        //List<Opportunity> oppList = [SELECT Id, Name, StageName, RecordTypeId FROM Opportunity WHERE Id IN :args];
        List<Opportunity> oppList = new List<Opportunity>();
       
        for (Id opp : args) {
            Opportunity opportunity = new Opportunity();
            opportunity.Id = opp;
            opportunity.RecordTypeId = openRecordTypeId;
            oppList.add(opportunity);
        }
       
        if (!oppList.isEmpty()) {
            update oppList;
        }
    }
}

//Trigger
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
