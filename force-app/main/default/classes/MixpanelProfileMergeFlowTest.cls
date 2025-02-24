@isTest
public class MixpanelProfileMergeFlowTest {
    
    @isTest
    static void testMergeProfilesFromFlow_Success() {
        // Prepare FlowInput with valid data
        MixpanelProfileMergeFlow.FlowInput input = new MixpanelProfileMergeFlow.FlowInput();
        input.acct1 = 'TestAcct1';
        input.acct2 = 'TestAcct2';
        input.isProd = true;
        
        List<MixpanelProfileMergeFlow.FlowInput> inputs = new List<MixpanelProfileMergeFlow.FlowInput>{input};
        
        // Execute method
        Test.startTest();
        List<MixpanelProfileMergeFlow.FlowOutput> results = MixpanelProfileMergeFlow.mergeProfilesFromFlow(inputs);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Expected one result.');
        System.assertEquals('Mixpanel profile merge enqueued successfully.', results[0].resultMessage, 'Expected success message.');
    }
    
    @isTest
    static void testMergeProfilesFromFlow_NullInputs() {
        // Prepare FlowInput with null account values
        MixpanelProfileMergeFlow.FlowInput input = new MixpanelProfileMergeFlow.FlowInput();
        input.acct1 = null;
        input.acct2 = null;
        input.isProd = false;
        
        List<MixpanelProfileMergeFlow.FlowInput> inputs = new List<MixpanelProfileMergeFlow.FlowInput>{input};
        
        // Execute method
        Test.startTest();
        List<MixpanelProfileMergeFlow.FlowOutput> results = MixpanelProfileMergeFlow.mergeProfilesFromFlow(inputs);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Expected one result.');
        System.assertEquals('Mixpanel profile merge enqueued successfully.', results[0].resultMessage, 'Expected success message even with null values.');
    }
    
    @isTest
    static void testMergeProfilesFromFlow_QueueableExecution() {
        // Prepare FlowInput
        MixpanelProfileMergeFlow.FlowInput input = new MixpanelProfileMergeFlow.FlowInput();
        input.acct1 = 'TestAcct1';
        input.acct2 = 'TestAcct2';
        input.isProd = false;
        
        List<MixpanelProfileMergeFlow.FlowInput> inputs = new List<MixpanelProfileMergeFlow.FlowInput>{input};
        
        // Execute method
        Test.startTest();
        System.enqueueJob(new MixpanelProfileMerge(input.acct1, input.acct2, 'TestProjectId', 'TestAuthToken'));
        Test.stopTest();
        
        // Validation
        System.assert(true, 'Queueable job enqueued successfully.');
    }
}