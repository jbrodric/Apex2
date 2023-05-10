public with sharing class MaintenanceRequestHelper {
  public static void ScheduleNextMaintenanceRequest(List<Case> lstCases) {
    Map<Id, Case> mapOldCaseIdToNewCase = new Map<Id, Case>();
    List<Equipment_Maintenance_Item__c> lstEMIInsert = new List<Equipment_Maintenance_Item__c>();

    for (Case c : lstCases) {
      if (
        (c.Type == 'Repair' || c.Type == 'Routine Maintenance') &&
        c.Status == 'Closed'
      ) {
        mapOldCaseIdToNewCase.put(
          c.Id,
          new Case(
            Type = 'Routine Maintenance',
            Subject = 'Routine Maintenance',
            Vehicle__c = c.Vehicle__c,
            Date_Reported__c = Date.today()
          )
        );
      }
    }

    if (mapOldCaseIdToNewCase.size() > 0)
      insert mapOldCaseIdToNewCase.values();

    for (Equipment_Maintenance_Item__c emi : [
      SELECT
        Id,
        Maintenance_Request__c,
        Maintenance_Request__r.Type,
        Maintenance_Request__r.Vehicle__c,
        Equipment__c
      FROM Equipment_Maintenance_Item__c
      WHERE Maintenance_Request__c IN :mapOldCaseIdToNewCase.keySet()
    ]) {
      lstEMIInsert.add(new Equipment_Maintenance_Item__c());
    }

    if (lstEMIInsert.size() > 0)
      insert lstEMIInsert;
  }
}
