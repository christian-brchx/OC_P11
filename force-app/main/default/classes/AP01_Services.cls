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
}