@isTest(seeAllData=false)
public with sharing class WarehouseCalloutServiceTest {
  @isTest
  static void TestCallout() {
    WarehouseCalloutServiceMock mock = new WarehouseCalloutServiceMock();
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    System.enqueueJob(new WarehouseCalloutService());
    Test.stopTest();

    System.assertEquals(22, [SELECT COUNT() FROM Product2]);
    System.assertEquals(
      'Generator 1000 kW',
      [
        SELECT name
        FROM Product2
        WHERE Warehouse_SKU__c = '55d66226726b611100aaf741'
      ][0]
      .name
    );
  }
}
