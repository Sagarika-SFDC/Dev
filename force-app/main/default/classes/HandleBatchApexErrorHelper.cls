public with sharing class HandleBatchApexErrorHelper {

    public static void afterInsert(List<BatchApexErrorEvent> errorEventList){
        Set<Id> asyncApexJobIdSet  = new Set<Id>();
        List<Exception_Log__c> exceptionLogs = new List<Exception_Log__c>();
        for(BatchApexErrorEvent obj : errorEventList){
            asyncApexJobIdSet.add(obj.AsyncApexJobId);
        }
        Map<Id, AsyncApexJob> apexJobs = new Map<Id, AsyncApexJob>(
            [
                SELECT id, ApexClass.Name
                FROM AsyncApexJob
                WHERE Id IN :asyncApexJobIdSet
            ]
        );
        for(BatchApexErrorEvent evt : errorEventList){
            AsyncApexJob jobDetails = apexJobs.get(evt.AsyncApexJobId);
            String apexClassName = jobDetails.ApexClass.Name;
            if(jobDetails.ApexClass.Name == 'leadCheckDuplicateBatch'){
                for(String item : evt.JobScope.split(',')){
                    Exception_Log__c expLog = new Exception_Log__c();
                    expLog.Record_Id__c = item;
                    expLog.Type__c = evt.ExceptionType;
                    expLog.Object__c = 'Lead';
                    expLog.Exception_Details__c = evt.Message;
                    exceptionLogs.add(expLog);
                }
            }
        }
        try{
            if(exceptionLogs.size() > 0){
                Database.insert(exceptionLogs);
            }
            
        }catch(Exception ex){
            system.debug('Exception while creating exception logs'+ ex.getMessage());
        }
    }
}