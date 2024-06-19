/*
Purpose : This batch class is to identify duplicate leads based on LeadSource and either of the two attributes (Name/email/Phone)
*/
public class leadCheckDuplicateBatch implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {

    private String query = ' SELECT Id, LeadSource, FirstName, LastName, Salutation, Email, Phone ' +
                            ' FROM Lead ' +
                            ' WHERE LeadSource != NULL ' + 
                            ' AND (Name != NULL OR Email != NULL OR Phone != NULL) ' ;
    private String additionalQuery = ' ORDER BY CreatedDate DESC' ;  
    
    // tester can pass the date range using this method to test the batch for specific records.
    public leadCheckDuplicateBatch( Integer noOfDays) {
        
        noOfDays = noOfDays > 0 ? noOfDays : 1;
        query += ' AND CreatedDate = Last_N_days: '+ String.valueOf(noOfDays);

    }
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(query + additionalQuery);
    }
    /*
    Execute method with Batch size 1
    Compare the masterlead with existing leads in order to identify the duplicates
    */
    //==================
    public void execute(Database.BatchableContext bc, List<Lead> listLead) {
        Lead masterLead = new Lead();
        List<Lead> duplicateLeads = new  List<Lead>();
        if(!listLead.isEmpty()){
            masterLead = listLead.get(0);
            String name = masterLead.FirstName + ' ' + masterLead.LastName;
            duplicateLeads =  [ SELECT Id, LeadSource, FirstName, LastName,  Salutation, Email, Phone 
                                FROM Lead 
                                WHERE LeadSource =: masterLead.LeadSource
                                AND Id !=: masterLead.Id 
                                AND ((Name =: Name AND Email =: masterLead.Email )
                                    OR ( Name =: Name AND Phone =: masterLead.Phone)
                                    OR ( Email =: masterLead.Email AND Phone =: masterLead.Phone))

                                ORDER BY CreatedDate DESC];
        }
        //merge duplicate leads to master lead
        if(duplicateLeads.size() > 0){
            mergeLeads(masterLead, duplicateLeads);
            //Database.merge(masterLead, duplicateLeads);
        }
    }
    public String nullValidate(String data){
        return  data == null ? null : data.toLowerCase();
    } 
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing has been completed.');
    }
    
    private void mergeLeads(Lead masterLead, List<Lead> leads) {
        // Assume the first lead in the list is the master record

        Integer mergecount = 0;
        for (Integer i = 0; i < leads.size(); i += 2) {
            try {
                // Create a list to hold up to two duplicate leads
                List<Lead> duplicateLeads = new List<Lead>();
                duplicateLeads.add(leads[i]);
                if(i+1 < leads.size()){
                    duplicateLeads.add(leads[i+1]);    
                }
                // Merge the duplicate leads into the master lead
                mergecount++;
                if(mergecount < 100){
                	Database.merge(masterLead, duplicateLeads);
                    break;
                }
                
            } catch (Exception e) {
                System.debug('Error merging leads: ' + e.getMessage());
            }
        }
    }
    // With Batch Size 100
    /*
    Naming Convention Consideration for duplicate matching criteria
    sc1 - leadSource+ name + Phone
    sc2 - leadSource + name + email
    sc3 - leadSource + email + Phone
    -> Batch size as 100 
                -> iterate over to get the master and duplicates
                -> Comapre the result with existing 49,000 records from database to find if there is any duplicate before merge
    */
    //==================
    /*public void execute(Database.BatchableContext bc, List<Lead> listLead) {

        Map<String, Lead> masterLeadMap_sc1 = new Map<String, Lead>( ); 
        Map<String, Lead> masterLeadMap_sc2 = new Map<String, Lead>(); 
        Map<String, Lead> masterLeadMap_sc3 = new Map<String, Lead>();
        Set<String> leadSourceSet = new Set<String>();
        Set<String> NameSet = new Set<String>();
        Set<String> EmailSet = new Set<String>();
        Set<String> PhoneSet = new Set<String>();
        Set<Id> listLeadIds = new Set<Id>();

        List<Lead> duplicateLeads_sc1 = new List<Lead>();
        List<Lead> duplicateLeads_sc2 = new List<Lead>();
        List<Lead> duplicateLeads_sc3 = new List<Lead>();
        if(!listLead.isEmpty()){
            for(lead lead: listLead){
                string sc1 = nullValidate(lead.LeadSource) +  '_' + nullValidate(lead.Name) + '_' + nullValidate(lead.Phone);
                string sc2 = nullValidate(lead.LeadSource) +  '_' + nullValidate(lead.Name ) + '_' +  nullValidate(lead.Email);
                string sc3 = nullValidate(lead.LeadSource) +  '_' + nullValidate(lead.Email)  + '_' + nullValidate( lead.Phone);
                if(!masterLeadMap_sc1.containsKey(sc1)){
                    masterLeadMap_sc1.put(sc1, lead);
                }else {
                    duplicateLeads_sc1.add(lead);
                }
                if(!masterLeadMap_sc2.containsKey(sc2)){
                    masterLeadMap_sc2.put(sc1, lead);
                }else{
                    duplicateLeads_sc2.add(lead);
                }
                if(!masterLeadMap_sc3.containsKey(sc3)){
                    masterLeadMap_sc3.put(sc1, lead);
                }else{
                    duplicateLeads_sc3.add(lead);
                }
                NameSet.add(lead.FirstName + ' ' + lead.LastName);
                EmailSet.add(lead.email);
                PhoneSet.add(lead.phone);
                leadSourceSet.add(lead.LeadSource);
                listLeadIds.add(lead.Id);
            }
         }
            for( lead lead : [
                SELECT Id, LeadSource, FirstName, LastName, Salutation, Email, Phone 
                FROM Lead 
                WHERE LeadSource =: LeadSourceSet 
                AND ID NOT IN : listLeadIds
                AND (Name =: NameSet OR Email =: EmailSet OR Phone =: PhoneSet)
                ORDER BY CreatedDate DESC
            ])

            {
                if(masterLeadMap_sc1.containsKey(nullValidate(lead.LeadSource) +  '_' +nullValidate(lead.Name) + '_' + nullValidate(lead.Phone)) ){
                    duplicateLeads_sc1.add(lead);
                }
                if(masterLeadMap_sc2.containsKey(nullValidate(lead.LeadSource) +  '_' +nullValidate(lead.Name) + '_' + nullValidate(lead.Email)) ){
                    duplicateLeads_sc2.add(lead);
                }
                if(masterLeadMap_sc3.containsKey(nullValidate(lead.LeadSource) +  '_' +nullValidate(lead.Phone) + '_' + nullValidate(lead.Email)) ){
                    duplicateLeads_sc3.add(lead);
                }

            for (String key : masterLeadMap_sc1.keySet()) {
                Database.merge( masterLeadMap_sc1.get(key), duplicateLeads_sc1);
            }
            for (String key : masterLeadMap_sc2.keySet()) {
            Database.merge( masterLeadMap_sc2.get(key), duplicateLeads_sc2);
            }
            for (String key : masterLeadMap_sc3.keySet()) {
                Database.merge( masterLeadMap_sc3.get(key), duplicateLeads_sc3);
            }
        }
    }*/

}