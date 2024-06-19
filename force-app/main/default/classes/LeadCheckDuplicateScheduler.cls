public with sharing class LeadCheckDuplicateScheduler implements Schedulable {
    public LeadCheckDuplicateScheduler() {

    }
    public void execute(SchedulableContext sc) {
        leadCheckDuplicateBatch batch = new leadCheckDuplicateBatch();
        Database.executeBatch(batch, 1); 
    }
}