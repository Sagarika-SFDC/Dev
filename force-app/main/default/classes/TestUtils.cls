public with sharing class TestUtils {
    public TestUtils() {

    }
    public static void createLeads(){
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(LastName = 'Smith', FirstName = 'John', Email = 'test@example.com', phone = '+1 9999999999', LeadSource = 'Web', Company = 'ABC Corp'));
        leads.add(new Lead(LastName = 'Smith', FirstName = 'Jack', Email = 'test@example.com', phone = '+1 9999999999', LeadSource = 'Web', Company = 'ABC Corp'));
        leads.add(new Lead(LastName = 'Williams', FirstName = 'Mike', Email = 'test1@example.com', phone = '+1 9999999998', LeadSource = 'Referral', Company = 'ABC Corp'));
        leads.add(new Lead(LastName = 'Jones', FirstName = 'Nick', Email = 'test2@example.com', phone = '+1 9999999997', LeadSource = 'Web', Company = 'ABC Corp'));
        leads.add(new Lead(LastName = 'Brown', FirstName = 'Jack', Email = 'test@example.com', phone = '+1 9999999999', LeadSource = 'Web', Company = 'ABC Corp'));
        
        insert leads;
    }
}