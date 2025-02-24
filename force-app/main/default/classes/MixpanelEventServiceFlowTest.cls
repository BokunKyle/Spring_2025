@isTest
public class MixpanelEventServiceFlowTest {    
    @isTest
    static void testTrackMixpanelEventFromFlow_Success() {
        // Prepare valid input
        FlowEventInput input = new FlowEventInput();
        input.bokunId = '123456';
        input.eventName = 'Salesforce Lead Created';
        input.isProdEvent = false;
        input.propertyKeys = new List<String>{'Key1', 'Key2'};
        input.propertyValues = new List<String>{'Value1', 'Value2'};
        
        List<FlowEventInput> inputs = new List<FlowEventInput>{input};
        
        // Execute test
        Test.startTest();
        List<MixpanelEventServiceFlow.FlowOutput> results = MixpanelEventServiceFlow.trackMixpanelEventFromFlow(inputs);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Expected 1 result');
        System.assertEquals('Mixpanel event enqueued successfully.', results[0].resultMessage, 'Expected success message');
    }
    
    @isTest
    static void testTrackMixpanelEventFromFlow_InvalidEventName() {
        // Prepare invalid event input
        FlowEventInput input = new FlowEventInput();
        input.bokunId = '123456';
        input.eventName = 'InvalidEvent'; // Not in custom metadata
        input.isProdEvent = false;
        
        List<FlowEventInput> inputs = new List<FlowEventInput>{input};
        
        // Execute test
        Test.startTest();
        List<MixpanelEventServiceFlow.FlowOutput> results = MixpanelEventServiceFlow.trackMixpanelEventFromFlow(inputs);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Expected 1 result');
        System.assert(results[0].resultMessage.contains('Invalid event name'), 'Expected error message for invalid event');
    }
    
    @isTest
    static void testTrackMixpanelEventFromFlow_InvalidBokunId() {
        // Prepare input with invalid bokunId
        FlowEventInput input = new FlowEventInput();
        input.bokunId = ''; // Empty ID
        input.eventName = 'Salesforce Lead Created';
        input.isProdEvent = false;
        
        List<FlowEventInput> inputs = new List<FlowEventInput>{input};
        
        // Execute test
        Test.startTest();
        List<MixpanelEventServiceFlow.FlowOutput> results = MixpanelEventServiceFlow.trackMixpanelEventFromFlow(inputs);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Expected 1 result');
        System.assert(results[0].resultMessage.contains('Invalid bokunId'), 'Expected error message for invalid bokunId');
    }

}