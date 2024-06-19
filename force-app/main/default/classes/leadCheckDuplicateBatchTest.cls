@isTest
public with sharing class leadCheckDuplicateBatchTest {
    
    @testSetup
    static void setup() {
        // Create test data
        TestUtils.createLeads();
    }

    @isTest
    static void testBatchExecution() {

        
        Test.startTest();
        Database.executeBatch(new leadCheckDuplicateBatch(),1);
        Test.stopTest();

        List<Lead> remainingLeads = [SELECT Id, Email, LeadSource FROM Lead];
        
        // There should be 3 unique leads left, as two pairs should have been merged
        System.assertEquals(3, remainingLeads.size());
        
        // Verify that the leads with the same email and lead source were merged
        for (Lead lead : remainingLeads) {
            if (lead.Email == 'test@example.com' && lead.LeadSource == 'Web') {
                // Only one lead should remain for this email and lead source combination
                Integer count = [SELECT COUNT() FROM Lead WHERE Email = 'test@example.com' AND LeadSource = 'Web'];
                System.assertEquals(1, count);
            }
        }
    }

}