global class BP01_AccountWithoutOrderNorTask implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext info){ 
        System.Debug('BP01_AccountWithoutOrderNorTask.start');
        // Get accounts without order
        return Database.getQueryLocator('SELECT Id, Name FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');
        //return Database.getQueryLocator('SELECT Account.Id, Account.Name, Account.Chiffre_d_affaires__c FROM Account WHERE Account.Id IN (SELECT AccountID FROM Order WHERE Status = \'Activated\')');
    }
    
    global void execute(Database.BatchableContext info, List<Account> scope){
        System.Debug('BP01_AccountWithoutOrderNorTask.execute Nb Account = '+scope.size());
    }
    
    global void finish(Database.BatchableContext info){     
       
    }
}