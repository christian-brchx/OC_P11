global class BP01_AccountWithoutOrderNorTask implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext info){ 
        return new Database.QueryLocator();
    }
    
    global void execute(Database.BatchableContext info, List<Account> scope){
    }
    
    global void finish(Database.BatchableContext info){     
       
    }
}