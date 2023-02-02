global class BP01_Scheduler implements Schedulable {

    public static String CRON_EXP = '0 0 1 ? * 2#1';

    global void execute(SchedulableContext SC) {
        System.debug('BP01_Scheduler.execute : BEGIN');
        // Check the schedule Expression
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :SC.getTriggerId()];
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // execute the batch
        ID batchprocessid = Database.executeBatch(new BP01_AccountWithoutOrderNorTask());
        System.debug('BP01_Scheduler.execute : END');
    }
}