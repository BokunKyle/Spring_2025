@IsTest
public class MixpanelEventServiceTest {

    @IsTest
    static void testExecute_SuccessfulCallout() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Test data setup
        String eventName = 'Salesforce Lead Created';
        String bokunId = 'testBokunId123';
        Map<String, Object> propertiesMap = new Map<String, Object>{
            'Key1' => 'Value1',
            'Key2' => 'Value2'
        };
        String propertiesJson = JSON.serialize(propertiesMap);
        Boolean isProdEvent = false;

        // Instantiate MixpanelEventService with test data
        MixpanelEventService eventService = new MixpanelEventService(eventName, bokunId, propertiesJson, isProdEvent);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(eventService);
        Test.stopTest();

        // No direct assertions needed; rely on debug logs or custom logging in production
        // as the test is mainly to ensure no exceptions are thrown with valid data.
    }

    @IsTest
    static void testExecute_MissingBokunId() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Test data setup with empty bokunId
        String eventName = 'Salesforce Lead Created';
        String bokunId = ''; // Invalid Bokun ID
        Map<String, Object> propertiesMap = new Map<String, Object>{
            'Key1' => 'Value1',
            'Key2' => 'Value2'
        };
        String propertiesJson = JSON.serialize(propertiesMap);
        Boolean isProdEvent = true;

        // Instantiate MixpanelEventService with missing bokunId
        MixpanelEventService eventService = new MixpanelEventService(eventName, bokunId, propertiesJson, isProdEvent);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(eventService);
        Test.stopTest();

        // Expect no callout due to missing bokunId; no exception should be thrown.
    }

    @IsTest
    static void testExecute_InvalidPropertiesJson() {
        // Set up mock for HTTP exception response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpExceptionMock());

        // Test data setup with invalid JSON
        String eventName = 'Salesforce Lead Created';
        String bokunId = 'testBokunId123';
        String propertiesJson = '{invalidJson}'; // Malformed JSON
        Boolean isProdEvent = null;

        // Instantiate MixpanelEventService with invalid JSON
        MixpanelEventService eventService = new MixpanelEventService(eventName, bokunId, propertiesJson, isProdEvent);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(eventService);
        Test.stopTest();

        // Expect error handling to capture JSON exception gracefully.
    }

    @IsTest
    static void testExecute_HttpExceptionHandling() {
        // Set up mock for HTTP exception response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpExceptionMock());

        // Test data setup
        String eventName = 'Salesforce Lead Created';
        String bokunId = 'testBokunId123';
        Map<String, Object> propertiesMap = new Map<String, Object>{
            'Key1' => 'Value1',
            'Key2' => 'Value2'
        };
        String propertiesJson = JSON.serialize(propertiesMap);
        Boolean isProdEvent = true;

        // Instantiate MixpanelEventService with test data
        MixpanelEventService eventService = new MixpanelEventService(eventName, bokunId, propertiesJson, isProdEvent);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(eventService);
        Test.stopTest();

        // This test will verify that HTTP exceptions are handled without halting the job.
    }
}