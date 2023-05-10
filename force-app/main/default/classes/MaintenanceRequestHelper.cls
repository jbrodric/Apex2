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
            Subject = 'Routine Maintenance for ' + c.Vehicle__r.Name,
            Vehicle__c = c.Vehicle__c,
            Date_Reported__c = Date.today()
          )
        );
      }
    }

    for (AggregateResult aggr : [
      SELECT
        Maintenance_Request__c,
        MIN(Equipment__r.Maintenance_Cycle__c) min_cycle
      FROM Equipment_Maintenance_Item__c
      WHERE Maintenance_Request__c IN :mapOldCaseIdToNewCase.keySet()
      GROUP BY Maintenance_Request__c
    ]) {
      mapOldCaseIdToNewCase.get((Id) aggr.get('Maintenance_Request__c'))
        .Date_Due__c = Date.today().addDays((Integer) aggr.get('min_cycle'));
    }

    if (mapOldCaseIdToNewCase.size() > 0)
      insert mapOldCaseIdToNewCase.values();

    for (Equipment_Maintenance_Item__c emi : [
      SELECT Id, Maintenance_Request__c, Equipment__c, Quantity__c
      FROM Equipment_Maintenance_Item__c
      WHERE Maintenance_Request__c IN :mapOldCaseIdToNewCase.keySet()
    ]) {
      lstEMIInsert.add(
        new Equipment_Maintenance_Item__c(
          Equipment__c = emi.Equipment__c,
          Maintenance_Request__c = mapOldCaseIdToNewCase.get(
              emi.Maintenance_Request__c
            )
            .Id,
          Quantity__c = emi.Quantity__c
        )
      );
    }

    if (lstEMIInsert.size() > 0)
      insert lstEMIInsert;
  }
}
