public class AP01_Services {

    public static Set<Id> checkUpdateOrders (Map<Id,Order> mapOrds) {
        List<Order> orders = [SELECT Id, Name, (SELECT Id FROM OrderItems) FROM Order WHERE Id IN :mapOrds.keyset()];
        Set<Id> idOrdInError = new Set<Id>();
        for (Order ord : orders) {
            // No product on the order ?
            if (ord.OrderItems.size() == 0) {
                idOrdInError.add(ord.id);
            }
        }
        return idOrdInError;
    }

    public static void checkDeleteOrders (Set<Id> idAccounts) {
        List<Account> accounts = [SELECT Id, Name, (SELECT Id FROM Orders) FROM Account WHERE Id IN :idAccounts];
        List<Account> accToDeactivate = new List<Account>();
        for (Account acc : accounts) {
            // No order on the account ?
            if (acc.Orders.size() == 0) {
                acc.Active__c = false;
                accToDeactivate.add(acc);
            }
        }
        update accToDeactivate;
    }

}