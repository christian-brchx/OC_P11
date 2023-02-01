global class BP01_AccountWithoutOrderNorTask implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext info){ 
        System.Debug('BP01_AccountWithoutOrderNorTask.start');
        // Get accounts without order
        return Database.getQueryLocator('SELECT Id, Name FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');
    }
    
    global void execute(Database.BatchableContext info, List<Account> scope){
        Set<Id> idAccounts = AP01_Services.selectIdAccountsWithoutTask(new Map<Id,Account>(scope));
        AP01_Services.createTaskOnAccounts(idAccounts);
        System.Debug('BP01_AccountWithoutOrderNorTask.execute : Nb Accounts treated = '+idAccounts.size());
    }
    
    global void finish(Database.BatchableContext info){     
       
    }
}