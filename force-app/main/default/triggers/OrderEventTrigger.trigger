trigger OrderEventTrigger on Order_Event__e (after insert) {
    List<Task> tasks = new List<Task>();
    for(Order_Event__e event : Trigger.new){
        if(event.Has_Shipped__c){
            Task aTask = new Task(
                Priority = 'Medium',
                Subject = 'Follow up on shipped order ' + event.Order_Number__c,
                OwnerId = event.CreatedById
            );
            tasks.add(aTask);
        }

    }
    insert tasks;
}