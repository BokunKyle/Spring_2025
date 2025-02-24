@IsTest
public class MixpanelProfileServiceFlowTest {

    @IsTest
    static void testMixpanelProfileUpdateFromFlow() {
        // Create the test FlowProfileInput object
        List<FlowProfileInput> inputs = new List<FlowProfileInput>();

        // Add a test FlowProfileInput object
        FlowProfileInput testInput = new FlowProfileInput();
        testInput.bokunId = '123456';  // Sample Bokun ID
        testInput.isProdProfile = true;  // Set to true for prod profile
        
        // Add test property keys and values
        testInput.propertyKeys = new List<String>{'FirstName', 'LastName', 'Email'};
        testInput.propertyValues = new List<String>{'John', 'Doe', 'john.doe@example.com'};
        
        // Add the input to the list
        inputs.add(testInput);

        // Call the method under test
        Test.startTest();
        List<MixpanelProfileServiceFlow.FlowOutput> results = MixpanelProfileServiceFlow.MixpanelProfileUpdateFromFlow(inputs);
        Test.stopTest();
        
        // Validate the output message
        Assert.isNotNull(results, 'The results should not be null.');
        Assert.areEqual(1, results.size(), 'There should be exactly one result.');
        Assert.areEqual('Mixpanel Profile Update enqueued successfully.', results[0].resultMessage, 'The success message should match.');
    }

    // This method tests multiple inputs to validate flow handling of multiple records
    @IsTest
    static void testMixpanelProfileUpdateFromFlowMultipleInputs() {
        // Create the test FlowProfileInput objects
        List<FlowProfileInput> inputs = new List<FlowProfileInput>();

        // Add multiple test FlowProfileInput objects
        for (Integer i = 0; i < 3; i++) {
            FlowProfileInput testInput = new FlowProfileInput();
            testInput.bokunId = 'BokunId_' + i;  // Sample Bokun ID for each input
            testInput.isProdProfile = (Math.mod(i, 2) == 0);   // Alternate between true and false for isProdProfile
            
            // Add test property keys and values
            testInput.propertyKeys = new List<String>{'FirstName', 'LastName', 'Email'};
            testInput.propertyValues = new List<String>{'John' + i, 'Doe' + i, 'john.doe' + i + '@example.com'};
            
            // Add the input to the list
            inputs.add(testInput);
        }

        // Call the method under test with multiple inputs
        Test.startTest();
        List<MixpanelProfileServiceFlow.FlowOutput> results = MixpanelProfileServiceFlow.MixpanelProfileUpdateFromFlow(inputs);
        Test.stopTest();

        // Validate the output messages
        Assert.isNotNull(results, 'The results should not be null.');
        Assert.areEqual(3, results.size(), 'There should be exactly three results.');
        for (MixpanelProfileServiceFlow.FlowOutput result : results) {
            Assert.areEqual('Mixpanel Profile Update enqueued successfully.', result.resultMessage, 'The success message should match.');
        }
   }
   
}