trigger MaintenanceRequest on Case(before insert, before update) {
  MaintenanceRequestHelper.ScheduleNextMaintenanceRequest(Trigger.new);
}
