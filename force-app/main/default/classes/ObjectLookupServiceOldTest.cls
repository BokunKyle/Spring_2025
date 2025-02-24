@IsTest
public class ObjectLookupServiceOldTest {
    
    @IsTest
    static void testGetMixpanelIdWithValidCompanyId() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account', Company_Id__c = '12345');
        insert acc;

        List<Id> inputIds = new List<Id>{acc.Id};

        // Call the method
        List<ObjectLookupServiceOld.Output> results = ObjectLookupServiceOld.getMixpanelId(inputIds);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals('12345', results[0].resultValue);
    }

    @IsTest
    static void testGetMixpanelIdWithNullInputId() {
        List<Id> inputIds = new List<Id>{null};

        // Call the method
        List<ObjectLookupServiceOld.Output> results = ObjectLookupServiceOld.getMixpanelId(inputIds);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals('Invalid input_id', results[0].resultValue);
    }

    @IsTest
    static void testGetMixpanelIdWithInvalidObject() {
        // Set up test data with an object that does not have the relevant fields
        Contact contact = new Contact(LastName = 'Test Contact');
        insert contact;

        List<Id> inputIds = new List<Id>{contact.Id};

        // Call the method
        List<ObjectLookupServiceOld.Output> results = ObjectLookupServiceOld.getMixpanelId(inputIds);

    }
    
    @IsTest
    static void testLead() {
        // Set up test data with an object that does not have the relevant fields
        Lead l1 = new Lead(Mixpanel_Distinct_ID__c = '11111', LastName = 'lastname', Company = 'company');
        insert l1;

        List<Id> inputIds = new List<Id>{l1.Id};

        // Call the method
        List<ObjectLookupServiceOld.Output> results = ObjectLookupServiceOld.getMixpanelId(inputIds);
    }
    
    @IsTest
    static void testLeadWithoutID() {
        // Set up test data with an object that does not have the relevant fields
        Lead l2 = new Lead(Mixpanel_Distinct_ID__c = 'x', LastName = 'lastname2', Company = 'company2');
        insert l2;

        List<Id> inputIds = new List<Id>{l2.Id};

        // Call the method
        List<ObjectLookupServiceOld.Output> results = ObjectLookupServiceOld.getMixpanelId(inputIds);
    }
}