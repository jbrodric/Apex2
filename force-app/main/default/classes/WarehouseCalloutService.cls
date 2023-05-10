public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
  public void execute(QueueableContext context) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    // If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {
      List<Product2> lstEquipment = new List<Product2>();

      for (InventoryUpdate iupd : InventoryUpdate.parse(response.getBody())) {
        lstEquipment.add(
          new Product2(
            Name = iupd.name,
            Replacement_Part__c = true,
            Cost__c = iupd.cost,
            Current_Inventory__c = iupd.quantity,
            Lifespan_Months__c = iupd.lifespan,
            Maintenance_Cycle__c = iupd.maintenanceperiod,
            Warehouse_SKU__c = iupd.x_id
          )
        );
      }

      if (lstEquipment.size() > 0)
        upsert lstEquipment Product2.Fields.Warehouse_SKU__c;
    }
  }
}
