@isTest(seeAllData=false)
public with sharing class WarehouseSyncScheduleTest {
  public static String CRON_EXP = '0 0 0 15 3 ? 2042';

  @isTest
  static void TestSchedule() {
    WarehouseCalloutServiceMock mock = new WarehouseCalloutServiceMock();
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String jobId = System.schedule(
      'ScheduledApexTest',
      CRON_EXP,
      new WarehouseSyncSchedule()
    );
    Test.stopTest();

    System.assertNotEquals(null, jobId);
  }
}
