@isTest
private class AccountWithoutOrderNorTaskBatch_Test {
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
        ID batchProcessid = Database.executeBatch(new AccountWithoutOrderNorTaskBatch());
        Test.stopTest();
        // Get the Accounts updated
        List<Task> taskCreated = [SELECT Id, Subject, Status, Priority, IsReminderSet, ReminderDateTime FROM Task WHERE WhatId IN (SELECT Id FROM Account WHERE Name LIKE 'TestBatchAccountWithoutOrderNorTask%')];
        System.assertEquals(20,taskCreated.size(),'20 tâches doivent avoir été créées');
        for (Task tsk : taskCreated) {
            System.assertEquals('Call',tsk.Subject,'Le sujet de la tâche doit être call');
            System.assertEquals('Not Started',tsk.Status,'Le statut doit être \'Not Started\'');
            System.assertEquals('Normal',tsk.Priority,'La priorité doit être \'Normal\'');
            System.assert(tsk.IsReminderSet,'Le rappel doit être activé');
            System.assertEquals(Datetime.now().addDays(5).date(), tsk.ReminderDateTime.date(),'Le rappel doit être dans 5 jours');
        }

    }}