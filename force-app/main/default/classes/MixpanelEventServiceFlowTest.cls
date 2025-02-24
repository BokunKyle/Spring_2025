@IsTest
public class MixpanelEventServiceFlowTest {

    @IsTest
    static void testTrackMixpanelEventFromFlow_ValidEvent() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Prepare the FlowEventInput for a valid event
        FlowEventInput input = new FlowEventInput();
        input.bokunId = 'testBokunId123';
        input.eventName = 'Salesforce Lead Created';
        input.isProdEvent = true;
        input.propertyKeys = new List<String>{'Key1', 'Key2'};
        input.propertyValues = new List<String>{'Value1', 'Value2'};

        // Call the method
        List<FlowEventInput> inputs = new List<FlowEventInput>{input};
        List<MixpanelEventServiceFlow.FlowOutput> results = MixpanelEventServiceFlow.trackMixpanelEventFromFlow(inputs);

        // Assert that the response message indicates success
        System.assertEquals(1, results.size());
        System.assertEquals('Mixpanel event enqueued successfully.', results[0].resultMessage);
    }

    @IsTest
    static void testTrackMixpanelEventFromFlow_InvalidEvent() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Prepare the FlowEventInput for an invalid event
        FlowEventInput input = new FlowEventInput();
        input.bokunId = 'testBokunId456';
        input.eventName = 'Invalid Event';
        input.isProdEvent = false;
        input.propertyKeys = new List<String>{'Key1', 'Key2'};
        input.propertyValues = new List<String>{'Value1', 'Value2'};

        // Call the method
        List<FlowEventInput> inputs = new List<FlowEventInput>{input};
        List<MixpanelEventServiceFlow.FlowOutput> results = MixpanelEventServiceFlow.trackMixpanelEventFromFlow(inputs);

        // Assert that the response message indicates an invalid event
        System.assertEquals(1, results.size());
        System.assert(results[0].resultMessage.contains('Invalid event name: Invalid Event'), 'Expected message to contain "Invalid event name: Invalid Event"');
    }

    @IsTest
    static void testTrackMixpanelEventFromFlow_MissingProperties() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Prepare the FlowEventInput with missing properties
        FlowEventInput input = new FlowEventInput();
        input.bokunId = 'testBokunId789';
        input.eventName = 'Salesforce Lead Created';
        input.isProdEvent = false;
        input.propertyKeys = new List<String>{'Key1'};
        input.propertyValues = new List<String>{null};  // Intentionally set to null to simulate missing property

        // Call the method
        List<FlowEventInput> inputs = new List<FlowEventInput>{input};
        List<MixpanelEventServiceFlow.FlowOutput> results = MixpanelEventServiceFlow.trackMixpanelEventFromFlow(inputs);

        // Assert that the response message indicates success but without invalid properties
        System.assertEquals(1, results.size());
        System.assertEquals('Mixpanel event enqueued successfully.', results[0].resultMessage);
    }

    @IsTest
    static void testTrackMixpanelEventFromFlow_HttpException() {
        // Set up mock for HTTP exception response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpExceptionMock());

        // Prepare the FlowEventInput for a valid event
        FlowEventInput input = new FlowEventInput();
        input.bokunId = 'testBokunId123';
        input.eventName = 'Salesforce Lead Created';
        input.isProdEvent = false;
        input.propertyKeys = new List<String>{'Key1', 'Key2'};
        input.propertyValues = new List<String>{'Value1', 'Value2'};

        // Call the method
        List<FlowEventInput> inputs = new List<FlowEventInput>{input};
        List<MixpanelEventServiceFlow.FlowOutput> results = MixpanelEventServiceFlow.trackMixpanelEventFromFlow(inputs);

        // Assert that the response message is still indicating successful queuing
        System.assertEquals(1, results.size());
        System.assertEquals('Mixpanel event enqueued successfully.', results[0].resultMessage);
    }
    @IsTest
    static void testTrackMixpanelEventFromFlow_isProdEventNull() {
        // Set up mock for HTTP exception response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpExceptionMock());

        // Prepare the FlowEventInput for a valid event
        FlowEventInput input = new FlowEventInput();
        input.bokunId = 'testBokunId123';
        input.eventName = 'Salesforce Lead Created';
        input.propertyKeys = new List<String>{'Key1', 'Key2'};
        input.propertyValues = new List<String>{'Value1', 'Value2'};

        // Call the method
        List<FlowEventInput> inputs = new List<FlowEventInput>{input};
        List<MixpanelEventServiceFlow.FlowOutput> results = MixpanelEventServiceFlow.trackMixpanelEventFromFlow(inputs);

        // Assert that the response message is still indicating successful queuing
        System.assertEquals(1, results.size());
        System.assertEquals('Mixpanel event enqueued successfully.', results[0].resultMessage);
    }
}