global class AccountWithoutOrderNorTaskBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext info){ 
        System.Debug('AccountWithoutOrderNorTaskBatch.start');
        // Get accounts without order
        return Database.getQueryLocator('SELECT Id, Name FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');
    }
    
    global void execute(Database.BatchableContext info, List<Account> scope){
        Set<Id> idAccounts = AccountService.selectIdAccountsWithoutTask(new Map<Id,Account>(scope));
        AccountService.createTaskOnAccounts(idAccounts);
        System.Debug('AccountWithoutOrderNorTaskBatch.execute : Nb Accounts treated = '+idAccounts.size());
    }
    
    global void finish(Database.BatchableContext info){     
       
    }
}