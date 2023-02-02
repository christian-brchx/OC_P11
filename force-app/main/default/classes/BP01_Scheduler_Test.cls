@istest
class BP01_Scheduler_Test {

    static testmethod void testBP01_Scheduler() {
        Test.startTest();
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

            // Schedule the test job

            String jobId = System.schedule('testBP01_Scheduler',BP01_Scheduler.CRON_EXP,new BP01_Scheduler());

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                NextFireTime
                FROM CronTrigger WHERE id = :jobId];

            // Verify the expressions are the same
            System.assertEquals(BP01_Scheduler.CRON_EXP, 
                ct.CronExpression);

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);

            List<Task> taskNotCreated = [SELECT Id, Subject, Status, Priority, IsReminderSet, ReminderDateTime FROM Task WHERE WhatId IN (SELECT Id FROM Account WHERE Name LIKE 'TestBatchAccountWithoutOrderNorTask%')];
            System.assertEquals(0,taskNotCreated.size(),'aucune tâche ne doit avoir été créée');

        Test.stopTest();
        System.debug('BP01_Scheduler_Test AFTER STOPTEST');

        List<Task> taskCreated = [SELECT Id, Subject, Status, Priority, IsReminderSet, ReminderDateTime FROM Task WHERE WhatId IN (SELECT Id FROM Account WHERE Name LIKE 'TestBatchAccountWithoutOrderNorTask%')];
        System.assertEquals(20,taskCreated.size(),'20 tâches doivent avoir été créées');
        for (Task tsk : taskCreated) {
            System.assertEquals('Call',tsk.Subject,'Le sujet de la tâche doit être call');
            System.assertEquals('Not Started',tsk.Status,'Le statut doit être \'Not Started\'');
            System.assertEquals('Normal',tsk.Priority,'La priorité doit être \'Normal\'');
            System.assert(tsk.IsReminderSet,'Le rappel doit être activé');
            System.assertEquals(Datetime.now().addDays(5).date(), tsk.ReminderDateTime.date(),'Le rappel doit être dans 5 jours');
        }
    }
}