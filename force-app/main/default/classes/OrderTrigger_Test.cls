@isTest
private class OrderTrigger_Test {

    @testSetup static void createData() {
        // create one account with a CA of 0
        Account acc = TestDataFactory.createAccountActivated('Test Account');
 
        // Insert a test product.
        Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');
 
        // Create a custom price book
        Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
        
        // Create a price book entry with a custom price.
        Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);
 
        // create 2 orders without product on the account with shipmentcost of 10
        List<Order> ordersWithout = TestDataFactory.createOrdersOnAccount(acc.Id, 'Commande sans produit', 2, customPBId, 10);
 
        // create 2 order with product on the account with shipmentcost of 10
        List<Order> ordersWith = TestDataFactory.createOrdersOnAccount(acc.Id, 'Commande avec produit', 2, customPBId, 10);

        // create orderItem on the order with quantity of 1O and unitPrice of 100
        List<OrderItem> orderItems = TestDataFactory.createOrderItemsOnOrders(ordersWith, 10, 100, customPBEId);    
    }

    @isTest static void activateOrdersWithoutProductIsForbidden() {
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
            System.assert(sr.getErrors().size() == 1,'Une erreur doit avoir été retournée');
	        System.assertEquals('Vous devez ajouter un produit pour activer la commande',
	                             sr.getErrors()[0].getMessage());
        }
        List<Order> checkOrders = [SELECT Id, Name, Status FROM Order WHERE Name LIKE 'Commande sans produit%'];
        for (Order ord : checkOrders) {
            System.assertEquals('Draft',ord.Status,'La commande ' + ord.Name + ' devrait être désactivée');
        }


    }

    @isTest static void activateOrdersWithProductIsAllowed() {
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

    @isTest static void deleteAllOrdersMustDeactivateTheAccount() {
        // Get the account
        Account acc = [SELECT Id, Name, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        System.debug('deleteAllOrdersMustDeactivateTheAccount Active__c = ' + acc.Active__c);
        // Get all the orders of the account
        List<Order> ords = [SELECT Id FROM Order WHERE AccountId = :acc.Id];

        Test.startTest();
        delete ords;
        Test.stopTest();
        
        // Verify 
        // In this case the account must be deactivated
        Account accToCheck = [SELECT Id, Name, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        System.debug('deleteAllOrdersMustDeactivateTheAccount Active__c = ' + accToCheck.Active__c);
        System.assert(!accToCheck.Active__c,'Le compte ' + accToCheck.Name + ' devrait être désactivé');
    }
}