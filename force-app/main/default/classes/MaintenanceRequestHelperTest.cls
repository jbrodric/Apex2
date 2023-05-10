@isTest(seeAllData=false)
public with sharing class MaintenanceRequestHelperTest {
  @TestSetup
  static void makeData() {
    List<Case> lstMaintenanceRequests = new List<Case>();
    List<Product2> lstEquipment = new List<Product2>();
    List<Equipment_Maintenance_Item__c> lstEMI = new List<Equipment_Maintenance_Item__c>();
    List<Vehicle__c> lstVehicles = new List<Vehicle__c>();

    for (Integer i = 0; i < 30; i++) {
      lstVehicles.add(
        new Vehicle__c(name = 'Test Vehicle # ' + (i + 1).format())
      );
    }
    if (lstVehicles.size() > 0)
      insert lstVehicles;

    for (Integer i = 0; i < 30; i++) {
      lstEquipment.add(
        new Product2(
          name = 'Test Equipment # ' + (i + 1).format(),
          Maintenance_Cycle__c = i + 1,
          Replacement_Part__c = true
        )
      );
    }
    if (lstEquipment.size() > 0)
      insert lstEquipment;

    for (Integer i = 0; i < 300; i++) {
      lstMaintenanceRequests.add(
        new Case(
          Type = 'Routine Maintenance',
          Subject = 'Test Routine Maintenance',
          Vehicle__c = lstVehicles[i / 10].Id,
          Date_Reported__c = Date.today(),
          Status = 'New'
        )
      );
    }
    if (lstMaintenanceRequests.size() > 0)
      insert lstMaintenanceRequests;

    for (Integer i = 0; i < 900; i++) {
      lstEMI.add(
        new Equipment_Maintenance_Item__c(
          Equipment__c = lstEquipment[i / 30].Id,
          Maintenance_Request__c = lstMaintenanceRequests[i / 3].Id,
          Quantity__c = i / 30
        )
      );
    }
    if (lstEMI.size() > 0)
      insert lstEMI;
  }

  @isTest
  static void TestPositiveCases() {
    Case c = [
      SELECT
        Id,
        Status,
        Vehicle__c,
        Date_Due__c,
        (
          SELECT
            Id,
            Maintenance_Request__c,
            Equipment__c,
            Equipment__r.Maintenance_Cycle__c
          FROM Equipment_Maintenance_Items__r
        )
      FROM Case
      WHERE Subject = 'Test Routine Maintenance'
      LIMIT 1
    ];
    Test.startTest();
    c.Status = 'Closed';
    update c;
    Test.stopTest();

    System.assertEquals(30, [SELECT COUNT() FROM Vehicle__c]);
    System.assertEquals(30, [SELECT COUNT() FROM Product2]);
    System.assertEquals(301, [SELECT COUNT() FROM Case]);
    System.assertEquals(
      903,
      [SELECT COUNT() FROM Equipment_Maintenance_Item__c]
    );

    Case cNew = [
      SELECT
        Id,
        Vehicle__c,
        Date_Due__c,
        (
          SELECT
            Id,
            Maintenance_Request__c,
            Equipment__c,
            Equipment__r.Maintenance_Cycle__c
          FROM Equipment_Maintenance_Items__r
        )
      FROM Case
      WHERE Status = 'New' AND Subject = 'Routine Maintenance'
      LIMIT 1
    ][0];
    System.assertEquals(c.Vehicle__c, cNew.Vehicle__c);

    Integer nMinCycle = -1;
    for (Equipment_Maintenance_Item__c emi : c.Equipment_Maintenance_Items__r) {
      if (nMinCycle == -1)
        nMinCycle = (Integer) emi.Equipment__r.Maintenance_Cycle__c;
      else if (emi.Equipment__r.Maintenance_Cycle__c < nMinCycle)
        nMinCycle = (Integer) emi.Equipment__r.Maintenance_Cycle__c;
      System.assert(
        ContainsEquipment(cNew.Equipment_maintenance_Items__r, emi.Equipment__c)
      );
    }
    System.assertEquals(Date.today() + nMinCycle, cNew.Date_Due__c);
  }

  @isTest
  static void TestNegativeCases() {
    Case c = [
      SELECT Id, Status
      FROM Case
      WHERE Subject = 'Test Routine Maintenance'
      LIMIT 1
    ];
    Test.startTest();
    c.Status = 'Working';
    update c;
    Test.stopTest();

    System.assertEquals(30, [SELECT COUNT() FROM Vehicle__c]);
    System.assertEquals(30, [SELECT COUNT() FROM Product2]);
    System.assertEquals(300, [SELECT COUNT() FROM Case]);
    System.assertEquals(
      900,
      [SELECT COUNT() FROM Equipment_Maintenance_Item__c]
    );
  }
  @isTest
  static void TestBulkCases() {
    List<Case> lstCases = [
      SELECT Id, Status
      FROM Case
    ];
    Test.startTest();
    for (Case c : lstCases)
      c.Status = 'Closed';
    update lstCases;
    Test.stopTest();

    System.assertEquals(30, [SELECT COUNT() FROM Vehicle__c]);
    System.assertEquals(30, [SELECT COUNT() FROM Product2]);
    System.assertEquals(600, [SELECT COUNT() FROM Case]);
    System.assertEquals(
      1800,
      [SELECT COUNT() FROM Equipment_Maintenance_Item__c]
    );
  }

  private static Boolean ContainsEquipment(
    List<Equipment_Maintenance_Item__c> lstEmi,
    Id idEquipment
  ) {
    for (Equipment_Maintenance_Item__c emi : lstEmi) {
      if (emi.Equipment__c == idEquipment)
        return true;
    }

    return false;
  }
}
