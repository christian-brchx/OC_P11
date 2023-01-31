@isTest
public class TestDataFactory {
    public static Account createAccountActivated(String name) {
        Account a = new Account(Name=name, Phone = '0000000000');
        a.Active__c = true;
        insert a;
        return a;
    }

    public static List<Account> createAccounts(Integer numAccounts, String prefixName) {
        List<Account> accounts = new List<Account>();
        for (Integer i=0 ; i<numAccounts ; i++) {
            Account acc = new Account(Name=prefixName+i, Phone = '0000000000'); 
            accounts.add(acc);
        }
        insert accounts;
        return accounts;
    }

    public static List<Account> createAccountsWithOrders(Integer numAccounts, 
                                                        String prefixName, 
                                                        Integer amountOrder,
                                                        Id priceBookId,
                                                        Id pricebookEntryId) {

        List<Account> accounts = createAccounts(numAccounts, prefixName);
        List<Order> orders = new List<Order>();  
        for (Account acc : accounts){
            Order ord = new Order(Name = 'Commande ' + acc.Name, AccountId = acc.Id, EffectiveDate = Date.today(), 
                                    Status ='Draft', Pricebook2Id = priceBookId);
            orders.add(ord);
        }
        insert orders;
        return accounts;
    }

    public static List<Account> createAccountsWithCallTask(Integer numAccounts, 
                                                        String prefixName) {
        List<Account> accounts = createAccounts(numAccounts, prefixName);
        List<Task> tasks = new List<Task>();  
        for (Account acc :accounts){
            Task tsk = new Task(Type = 'Call ', WhatId = acc.Id, Description = 'Call test');
            tasks.add(tsk);
        }
        insert tasks;
        return accounts;
    }

    public static Id createTestProduct(String name, String family) {
        Product2 prod = new Product2(Name = name, 
            Family = family);
        insert prod;
        return prod.Id;
    }
    
    public static Id createCustomPriceBook(String name, Id prodId, Integer unitPrice) {
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prodId,
            UnitPrice = unitPrice, IsActive = true);
        insert standardPrice;
        
        // Create the custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        return customPB.Id;
    }

    public static Id createPriceBookEntryWithCustomPrice(Id pricebookId, Id productId, Integer unitPrice) {
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = productId,
                UnitPrice = unitPrice, IsActive = true);
        insert customPrice;
        return customPrice.Id;
    }

    public static List<Order> createOrdersOnAccount(Id accId, String nom, Integer numOrders, Id priceBookId, Integer shipmentCost) {
        List<Order> orders = new List<Order>();  
        for (Integer i=0;i<numOrders;i++) {
            Order ord = new Order(Name = nom + i, AccountId = accId, EffectiveDate = Date.today(), 
                                Status ='Draft', Pricebook2Id = priceBookId);
            ord.ShipmentCost__c = shipmentCost;
            orders.add(ord);
        }
        insert orders;
        return orders;
    }
    
    public static List<OrderItem> createOrderItemsOnOrders(List<Order> orders, Integer quantity, Integer unitPrice, Id pricebookEntryId) {
        List<OrderItem> orderItems = new List<OrderItem>();  
        for (Order ord : orders) {
            orderItems.add(new OrderItem (OrderId = ord.Id, Quantity=quantity, PricebookEntryId = pricebookEntryId, UnitPrice = unitPrice));
        }
        insert orderItems;
        return orderItems; 
    }
}