@isTest
private class BP01_AccountWithoutOrderNorTask_Test {
    @testSetup static void createData() {
        // Insert a test product.
        Id prodId = TestDataFactory.createTestProduct('Chemise Verte longue XYX', 'Chemise');
 
        // Create a custom price book
        Id customPBId = TestDataFactory.createCustomPriceBook('Custom Pricebook', prodId, 100);
        
        // Create a price book entry with a custom price.
        Id customPBEId = TestDataFactory.createPriceBookEntryWithCustomPrice(customPBId, prodId, 100);

        // Create 20 accounts with 1 order of 1000 with status 'Draft'
        List<Account> acc1 = TestDataFactory.createAccountsWithOrders(20,'TestBatchAccountWithOrder',1000, customPBId, customPBEId);
        // Create 20 accounts with 1 call task
        List<Account> acc2 = TestDataFactory.createAccountsWithCallTask(20,'TestBatchAccountWithCallTask');
        // Create 20 accounts without call task nor order
        List<Account> acc3 = TestDataFactory.createAccounts(20,'TestBatchAccountWithoutOrderNorTask');
     }

     @isTest static void testBatchMustCreateTwentyTasks() {
        Test.startTest();
        ID batchprocessid = Database.executeBatch(new BP01_AccountWithoutOrderNorTask());
        Test.stopTest();
        // Get the Accounts updated
        List<Task> taskToCreate = [SELECT Id, Subject, Status, Priority, ActivityDate FROM Task WHERE WhatId IN (SELECT Id FROM Account WHERE Name LIKE 'TestBatchAccountWithoutOrderNorTask%')];
        System.assertEquals(20,taskToCreate.size(),'20 tâches doivent avoir été créées');
    }}