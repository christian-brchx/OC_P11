trigger OrderTrigger on Order (before update, after delete) {
    if (Trigger.isUpdate) {
        List<Order> ordersToCheck = new List<Order>();
        for (Order ord :trigger.new) {
            if (ord.Status == 'Activated' && trigger.oldMap.get(ord.Id).Status == 'Draft' ) {
                ordersToCheck.add(ord);
            }
        }
        Set<Id> idOrdInError = AP01_Services.checkUpdateOrders(new Map<Id,Order>(ordersToCheck));
        for (Id idOrd : idOrdInError) {
            trigger.newMap.get(idOrd).addError('Vous devez ajouter un produit pour activer la commande');
        }
    }
    else if (Trigger.isDelete) {
        // Process after delete
        Set<Id> accountsToCheck = new Set<Id>();
        for (Order ord : trigger.old) {
            accountsToCheck.add(ord.AccountId);
        }
        AP01_Services.checkDeleteOrders(accountsToCheck);
    }
}