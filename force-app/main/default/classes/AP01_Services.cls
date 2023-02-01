public class AP01_Services {

    public static Set<Id> checkUpdateOrders (Map<Id,Order> mapOrds) {
        List<Order> orders = [SELECT Id, Name, (SELECT Id FROM OrderItems) FROM Order WHERE Id IN :mapOrds.keyset()];
        Set<Id> idOrdInError = new Set<Id>();
        for (Order ord : orders) {
            // No product on the order ?
            if (ord.OrderItems.size() == 0) {
                idOrdInError.add(ord.id);
            }
        }
        return idOrdInError;
    }

    public static void checkDeleteOrders (Set<Id> idAccounts) {
        List<Account> accounts = [SELECT Id, Name, (SELECT Id FROM Orders) FROM Account WHERE Id IN :idAccounts];
        List<Account> accToDeactivate = new List<Account>();
        for (Account acc : accounts) {
            // No order on the account ?
            if (acc.Orders.size() == 0) {
                acc.Active__c = false;
                accToDeactivate.add(acc);
            }
        }
        update accToDeactivate;
    }

    public static Set<Id> selectIdAccountsWithoutTask (Map<Id,Account> mapAccs) {
        Set<Id> idAccs = new Set<Id>(mapAccs.keyset());
        List<Task> tasks = [SELECT Id, Type, WhatId FROM Task WHERE WhatId IN :mapAccs.keyset()];
        For (Task tsk : tasks) {
            if (tsk.Type == 'Call') {
                idAccs.remove(tsk.WhatId);
            }
        }
        return idAccs;
    }

    public static void createTaskOnAccounts (Set<Id> idAccounts) {
        List<Task> tskToCreate = new List<Task>();
        for (Id idAcc : idAccounts) {
            Task tsk = new Task(Subject='Call',Status='Not Started',Priority='Normal');
            tsk.WhatId = idAcc;
            tsk.IsReminderSet = true;
            tsk.ReminderDateTime = Datetime.now().addDays(5);
            tskToCreate.add(tsk);
        }
        insert tskToCreate;
    }

}