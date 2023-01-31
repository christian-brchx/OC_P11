public class AP01_Services {

    public static void checkUpdateOrders (Map<Id,Order> mapOrds) {
        List<Order> orders = [SELECT Id, Name, (SELECT Id FROM OrderItems) FROM Order WHERE Id IN :mapOrds.keyset()];
        for (Order ord : orders) {
            // No product on the order ?
            if (ord.OrderItems.size() == 0) {
                ord.addError('Vous devez ajouter un produit pour activer la commande');
            }
        }
    }
}