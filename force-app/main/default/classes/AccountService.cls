public with sharing class AccountService {

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