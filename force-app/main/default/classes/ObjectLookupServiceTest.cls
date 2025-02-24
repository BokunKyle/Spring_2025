@isTest
public class ObjectLookupServiceTest {

    @testSetup
    static void setupTestData() {
        // Create test Accounts
        Account acc1 = new Account(Name = 'Test Account 1', Company_Id__c = 'COMP123');
        Account acc2 = new Account(Name = 'Test Account 2', Company_Id__c = 'COMP456');
        insert new List<Account>{acc1, acc2};

        // Create test Leads
        Lead lead1 = new Lead(LastName = 'Test Lead 1', Company = 'Test Company 1', Mixpanel_Distinct_ID__c = 'MIX123');
        Lead lead2 = new Lead(LastName = 'Test Lead 2', Company = 'Test Company 2', Mixpanel_Distinct_ID__c = 'MIX456');
        insert new List<Lead>{lead1, lead2};

        // Create a test Task for evaluating relationships
        Task task = new Task(Subject = 'Test Task', WhoId = lead1.Id);
        insert task;
    }

    @isTest
    static void testGetMixpanelIdWithValidIds() {
        // Retrieve test data
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        Lead lead = [SELECT Id FROM Lead WHERE LastName = 'Test Lead 1' LIMIT 1];

        // Call the method
        List<Id> inputIds = new List<Id>{acc.Id, lead.Id};
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(inputIds);

        // Assert results
        System.assertEquals(2, results.size(), 'Expected two results');
        System.assertEquals('COMP123', results[0].resultValue, 'Expected Company_Id__c for Account');
        System.assertEquals('MIX123', results[1].resultValue, 'Expected Mixpanel_Distinct_ID__c for Lead');
    }

    @isTest
    static void testGetMixpanelIdWithNullId() {
        // Call the method with a null ID
        List<Id> inputIds = new List<Id>{null};
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(inputIds);

        // Assert results
        System.assertEquals(1, results.size(), 'Expected one result for null input');
        System.assertEquals(null, results[0].resultValue, 'Expected null result for null input');
    }

    @isTest
    static void testGetMixpanelIdWithInvalidObjectType() {
        // Create a Contact (not handled by getMixpanelId)
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = null);
        insert con;

        // Call the method with an invalid object type
        List<Id> inputIds = new List<Id>{con.Id};
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(inputIds);

        // Assert results
        System.assertEquals(1, results.size(), 'Expected one result for invalid object type');
        System.assertEquals(null, results[0].resultValue, 'Expected null result for invalid object type');
    }

    @isTest
    static void testEvaluateRelationships() {
        // Retrieve test Task
        Task task = [SELECT Id FROM Task WHERE Subject = 'Test Task' LIMIT 1];
    
        // Call private evaluateRelationships via public method
        List<Id> inputIds = new List<Id>{task.Id};
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(inputIds);
    
        // Assert results
        System.assertEquals(1, results.size(), 'Expected one result for relationship evaluation');
        System.assertEquals('MIX123', results[0].resultValue, 'Expected Mixpanel_Distinct_ID__c from Task relationship');
    }


    @isTest
    static void testGetMixpanelIdWithExceptionHandling() {
        // Insert a record and delete it to simulate a QueryException
        Account acc = new Account(Name = 'Test Account for Exception', Company_Id__c = 'COMP789');
        insert acc;
        delete acc;
    
        // Use the deleted ID
        List<Id> inputIds = new List<Id>{acc.Id};
    
        Test.startTest();
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(inputIds);
        Test.stopTest();
    
        // Assert the results
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals(null, results[0].resultValue, 'Expected null result due to exception');
    }
    
    @isTest
    static void testGetMixpanelIdWithContact() {
        // Create a test Account and Contact
        Account acc = new Account(Name = 'Test Account for Contact', Company_Id__c = 'COMP777');
        insert acc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
    
        // Log IDs to verify
        System.debug('Account ID: ' + acc.Id);
        System.debug('Contact ID: ' + con.Id);
    
        // Call the public method
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(new List<Id>{con.Id});
    
        // Log results for debugging
        System.debug('Results are: ' + results);
    
        // Assert the result
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals('COMP777', results[0].resultValue, 'Expected Company_Id__c from related Account');
    }

    @isTest
    static void testGetMixpanelIdWithInvalidOrDeletedId() {
        // Insert and delete a record to simulate a QueryException
        Account acc = new Account(Name = 'Test Account for Exception', Company_Id__c = 'X');
        insert acc;
        delete acc;
    
        // Call the public method with the deleted record's ID
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(new List<Id>{acc.Id});
    
        // Assert the result
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals(null, results[0].resultValue, 'Expected null result for deleted record');
    }
    
    @isTest
    static void testGetMixpanelId_OneLevel() {
        // Create an Account with a valid Company_Id__c
        Account acc = new Account(Name = 'Test Account', Company_Id__c = 'COMP111');
        insert acc;
    
        // Create a Task with WhatId pointing to the Account
        Task task = new Task(Subject = 'Test Task', WhatId = acc.Id);
        insert task;
    
        // Call the public method with the Task ID
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(new List<Id>{task.Id});
    
        // Assert the result
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals('COMP111', results[0].resultValue, 'Expected Company_Id__c from related Account');
    }
      


    @isTest
    static void testGetMixpanelId_TwoLevels() {
        // Create an Account with a valid Company_Id__c
        Account acc = new Account(Name = 'Test Account', Company_Id__c = 'COMP222');
        insert acc;
    
        // Create an intermediate Contact with WhatId pointing to the Account
        Contact intermediateContact = new Contact(FirstName = 'Intermediate',LastName = 'Contact', AccountId = acc.Id);
        insert intermediateContact;
      
        Task rootTask = new Task(Subject = 'Root Task', WhoId = intermediateContact.Id);
        insert rootTask;
    
        // Call the public method with the root Task ID
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(new List<Id>{rootTask.Id});
    
        // Assert the result
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals('COMP222', results[0].resultValue, 'Expected Company_Id__c from two-level relationship');
    }



    @isTest
    static void testGetMixpanelId_NoValidId() {
        // Create a Task with no WhatId or WhoId
        Task task = new Task(Subject = 'Task Without Relationships');
        insert task;
    
        // Call the public method with the Task ID
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(new List<Id>{task.Id});
    
        // Assert the result
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals(null, results[0].resultValue, 'Expected null when no valid ID is found');
    }
    
    @isTest
    static void testGetMixpanelId_WithLead() {
        // Create a Lead with a valid Mixpanel_Distinct_ID__c
        Lead lead = new Lead(LastName = 'Test Lead', Company = 'Test Company', Mixpanel_Distinct_ID__c = 'MIX999');
        insert lead;
    
        // Call the public method with the Lead ID
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(new List<Id>{lead.Id});
    
        // Assert the result
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals('MIX999', results[0].resultValue, 'Expected Mixpanel_Distinct_ID__c for Lead');
    }
    
    @isTest
    static void testGetMixpanelId_WithAccount() {
        // Create an Account with a valid Company_Id__c
        Account acc = new Account(Name = 'Test Account', Company_Id__c = 'COMP789');
        insert acc;
    
        // Call the public method with the Account ID
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(new List<Id>{acc.Id});
    
        // Assert the result
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals('COMP789', results[0].resultValue, 'Expected Company_Id__c for Account');
    }
    
    @isTest
    static void testGetMixpanelId_null() {
       
        Case intermediateCase = new Case(Origin = 'Email');
        insert intermediateCase;
      
        Task rootTask = new Task(Subject = 'Root Task', WhatId = intermediateCase.Id);
        insert rootTask;
    
        // Call the public method with the root Task ID
        List<ObjectLookupService.Output> results = ObjectLookupService.getMixpanelId(new List<Id>{rootTask.Id});
    
        // Assert the result
        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals(null, results[0].resultValue, 'Expected Null');
    }
    


}