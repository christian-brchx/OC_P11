trigger OrderTrigger on Order (before update, after delete) {
    if (Trigger.isUpdate) {
        List<Order> ordersToCheck = new List<Order>();
        for (Order ord :trigger.new) {
            System.debug('OrderTrigger NewOrder :' + ord.Name + ' Status : ' + ord.Status);
            System.debug('OrderTrigger OldOrder :' + trigger.oldMap.get(ord.Id).Name + ' Status : ' + trigger.oldMap.get(ord.Id).Status);
            if (ord.Status == 'Activated' && trigger.oldMap.get(ord.Id).Status == 'Draft' ) {
                ordersToCheck.add(ord);
            }
        }
        AP01_Services.checkUpdateOrders(new Map<Id,Order>(ordersToCheck));
    }
    else if (Trigger.isDelete) {
        // Process after delete
    }
}