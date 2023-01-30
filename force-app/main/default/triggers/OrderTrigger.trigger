trigger OrderTrigger on ORDER (before update, after delete) {
    if (Trigger.isUpdate) {
        // Process before insert
    }
    else if (Trigger.isDelete) {
        // Process after delete
    }
}