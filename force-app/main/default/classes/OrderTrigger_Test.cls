@isTest
private class OrderTrigger_Test {

    @testSetup static void createData() {
        // create one account with a CA of 0
        Account acc = TestDataFactory.createAccount('Test Account');
 
        // Insert a test product.
        Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');
 
        // Create a custom price book
        Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
        
        // Create a price book entry with a custom price.
        Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);
 
        // create 2 orders without product on the account with shipmentcost of 10
        List<Order> orderswithout = TestDataFactory.createOrdersOnAccount(acc.Id, 'Commande sans produit', 2, customPBId, 10);
 
        // create 2 order with product on the account with shipmentcost of 10
        List<Order> orderswith = TestDataFactory.createOrdersOnAccount(acc.Id, 'Commande avec produit', 2, customPBId, 10);

        // create orderItem on the order with quantity of 1O and unitPrice of 100
        List<OrderItem> orderItems = TestDataFactory.createOrderItemsOnOrders(orderswith, 10, 100, customPBEId);    
    }

    @isTest static void ActivateOrdersWithoutProductIsForbidden() {
        // Get the order without product
        List<Order> ords = [SELECT Id FROM Order WHERE Name LIKE 'Commande sans produit%'];
        for (Order ord : ords) {
            ord.Status = 'Activated';
        }

        Test.startTest();
        List<Database.SaveResult> results = Database.update(ords, false);
        Test.stopTest();
        
        // Verify 
        // In this case the update should have been stopped by the trigger,
        // so verify that we got back 2 errors.
        System.assertEquals(2,results.size(),'Deux résultats doivent avoir été retournés');
        for (Database.SaveResult sr : results) {
            System.assert(!sr.isSuccess(),'La mise à jour de la commande doit avoir échoué');
            System.assert(sr.getErrors().size() > 0,'Une erreur doit avoir été retournée');
        }
        List<Order> checkOrders = [SELECT Id, Name, Status FROM Order WHERE Name LIKE 'Commande sans produit%'];
        for (Order ord : checkOrders) {
            System.assertEquals('Draft',ord.Status,'La commande ' + ord.Name + ' devrait être désactivée');
        }


    }

    @isTest static void ActivateOrdersWithProductIsAllowed() {
        // Get the order with product
        List<Order> ords = [SELECT Id FROM Order WHERE Name LIKE 'Commande avec produit%'];
        for (Order ord : ords) {
            ord.Status = 'Activated';
        }

        Test.startTest();
        List<Database.SaveResult> results = Database.update(ords, false);
        Test.stopTest();
        
        // Verify 
        // In this case the update should have been stopped by the trigger,
        // so verify that we got back 2 errors.
        System.assertEquals(2,results.size(),'Deux résultats doivent avoir été retournés');
        for (Database.SaveResult sr : results) {
            System.assert(sr.isSuccess(),'La mise à jour de la commande doit avoir réussi');
        }

        List<Order> checkOrders = [SELECT Id, Name, Status FROM Order WHERE Name LIKE 'Commande avec produit%'];
        for (Order ord : checkOrders) {
            System.assertEquals('Activated',ord.Status,'La commande ' + ord.Name + ' devrait être activée');
        }

    }

}