@istest
class AccountWithoutOrderNorTaskScheduler_Test {

    static testmethod void testAccountWithoutOrderNorTaskScheduler() {
        // Verify the date of the run of the test (only in 2023)
        System.assert(datetime.newInstance(2023,12,31,23,59,59) > datetime.now(),
                      'Ce test ne fonctionne que jusqu\'au 31/12/2023');
    
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

            String jobId = System.schedule('testAccountWithoutOrderNorTaskScheduler',
                                            AccountWithoutOrderNorTaskScheduler.CRON_EXP,
                                            new AccountWithoutOrderNorTaskScheduler());

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                NextFireTime
                FROM CronTrigger WHERE id = :jobId];

            // Verify the expressions are the same
            System.assertEquals(AccountWithoutOrderNorTaskScheduler.CRON_EXP, 
                ct.CronExpression);

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);

            // Verify the date of the next run
            System.assertEquals(calculateNextFirstMondayOfTheMonth(),ct.NextFireTime,'La date de prochain lancement est erronée');

        Test.stopTest();
        System.debug('AccountWithoutOrderNorTaskScheduler_Test AFTER STOPTEST');
    }

    private static Datetime calculateNextFirstMondayOfTheMonth() {
        // table des premiers lundis du mois en 2023 et janvier 2024
        Integer[] tabMonday23 = new Integer[]{2,6,6,3,1,5,3,7,4,2,6,4,1};
        Datetime aujourdhui = datetime.now();
        if (aujourdhui > datetime.newInstance(2023,aujourdhui.month(),tabMonday23[aujourdhui.month()-1],1,0,0)) {
            return datetime.newInstance(2023,aujourdhui.month()+1,tabMonday23[aujourdhui.month()],1,0,0);
        } else {
            return datetime.newInstance(2023,aujourdhui.month(),tabMonday23[aujourdhui.month()-1],1,0,0);
        }
    }
}