@isTest
public class CustomConvertLeadTest {
    @testSetup
    static void setupTestData() {
        // Create an Account for Lead Conversion
        Account testAccount = new Account(Name = 'Test Account', Company_ID__c = '123');
        insert testAccount;
        
        // Create a Lead to Convert
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
    }
    
    @isTest
    static void testConvertLeadFromFlow_Success() {
        // Retrieve Test Data
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Prepare Input
        CustomConvertLead.ConvertLeadInput input = new CustomConvertLead.ConvertLeadInput();
        input.leadId = testLead.Id;
        input.accountId = testAccount.Id;
        List<CustomConvertLead.ConvertLeadInput> inputs = new List<CustomConvertLead.ConvertLeadInput>{input};
        
        // Execute Method
        Test.startTest();
        List<CustomConvertLead.ConvertLeadOutput> results = CustomConvertLead.convertLeadFromFlow(inputs);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Expected 1 result');
        System.assertEquals('Lead converted successfully.', results[0].resultMessage, 'Expected successful conversion message');
        
        // Ensure Lead is Converted
        Lead convertedLead = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, convertedLead.IsConverted, 'Lead should be marked as converted');
    }
    
    @isTest
    static void testConvertLeadFromFlow_Failure() {
        // Prepare Input with Invalid Lead ID
        CustomConvertLead.ConvertLeadInput input = new CustomConvertLead.ConvertLeadInput();
        input.leadId = '00QOv00000Nz7ovMAB'; // Invalid Lead ID
        input.accountId = null; // Invalid Account ID
        List<CustomConvertLead.ConvertLeadInput> inputs = new List<CustomConvertLead.ConvertLeadInput>{input};
        
        // Execute Method
        Test.startTest();
        List<CustomConvertLead.ConvertLeadOutput> results = CustomConvertLead.convertLeadFromFlow(inputs);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Expected 1 result');
        System.assert(results[0].resultMessage.contains('An error occurred during lead conversion'), 'Expected error message');
    }
}