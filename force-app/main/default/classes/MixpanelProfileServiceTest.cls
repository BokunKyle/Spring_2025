@IsTest
public class MixpanelProfileServiceTest {

    @IsTest
    static void testExecute_SuccessfulCallout() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Test data setup
        String bokunId = 'testBokunId123';
        Map<String, Object> propertiesMap = new Map<String, Object>{
            'Key1' => 'Value1',
            'Key2' => 'Value2'
        };
        String propertiesJson = JSON.serialize(propertiesMap);
        Boolean isProdProfile = false;

        // Instantiate MixpanelProfileService with test data
        MixpanelProfileService profileService = new MixpanelProfileService(bokunId, propertiesJson, isProdProfile);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(profileService);
        Test.stopTest();

        // No specific assertion; check debug logs or use custom logging for validation
    }

    @IsTest
    static void testExecute_MissingBokunId() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Test data setup with missing bokunId
        String bokunId = ''; // Invalid Bokun ID
        Map<String, Object> propertiesMap = new Map<String, Object>{
            'Key1' => 'Value1',
            'Key2' => 'Value2'
        };
        String propertiesJson = JSON.serialize(propertiesMap);
        Boolean isProdProfile = true;

        // Instantiate MixpanelProfileService with missing bokunId
        MixpanelProfileService profileService = new MixpanelProfileService(bokunId, propertiesJson, isProdProfile);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(profileService);
        Test.stopTest();

        // Expect no callout due to missing bokunId; no exception should be thrown
    }

    @IsTest
    static void testExecute_InvalidPropertiesJson() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Test data setup with invalid JSON
        String bokunId = 'testBokunId123';
        String propertiesJson = '{invalidJson}'; // Malformed JSON
        Boolean isProdProfile = false;

        // Instantiate MixpanelProfileService with invalid JSON
        MixpanelProfileService profileService = new MixpanelProfileService(bokunId, propertiesJson, isProdProfile);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(profileService);
        Test.stopTest();

        // Expect the service to catch the JSON deserialization error without throwing an unhandled exception
    }
    @IsTest
    static void testExecute_NullJson() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Test data setup with invalid JSON
        String bokunId = 'testBokunId123';
        String propertiesJson = ''; // Null JSON
        Boolean isProdProfile = false;

        // Instantiate MixpanelProfileService with invalid JSON
        MixpanelProfileService profileService = new MixpanelProfileService(bokunId, propertiesJson, isProdProfile);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(profileService);
        Test.stopTest();

        // Expect the service to catch the JSON deserialization error without throwing an unhandled exception
    }

    @IsTest
    static void testExecute_HttpErrorHandling() {
        // Set up mock for HTTP error response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpExceptionMock());

        // Test data setup
        String bokunId = 'testBokunId123';
        Map<String, Object> propertiesMap = new Map<String, Object>{
            'Key1' => 'Value1',
            'Key2' => 'Value2'
        };
        String propertiesJson = JSON.serialize(propertiesMap);
        Boolean isProdProfile = true;

        // Instantiate MixpanelProfileService with test data
        MixpanelProfileService profileService = new MixpanelProfileService(bokunId, propertiesJson, isProdProfile);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(profileService);
        Test.stopTest();

        // This test ensures that HTTP errors are handled gracefully in the execute method
    }

    @IsTest
    static void testExecute_NullPropertiesJson() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Test data setup with null propertiesJson
        String bokunId = 'testBokunId123';
        String propertiesJson = null; // Null properties JSON
        Boolean isProdProfile = true;

        // Instantiate MixpanelProfileService with null propertiesJson
        MixpanelProfileService profileService = new MixpanelProfileService(bokunId, propertiesJson, isProdProfile);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(profileService);
        Test.stopTest();

        // The job should handle the null propertiesJson without an unhandled exception
    }
    @IsTest
    static void testExecute_NullProdProfile() {
        // Set up mock for successful HTTP response
        Test.setMock(HttpCalloutMock.class, new MixpanelHttpMock());

        // Test data setup
        String bokunId = 'testBokunId123';
        Map<String, Object> propertiesMap = new Map<String, Object>{
            'Key1' => 'Value1',
            'Key2' => 'Value2'
        };
        String propertiesJson = JSON.serialize(propertiesMap);
        Boolean isProdProfile = null;

        // Instantiate MixpanelProfileService with test data
        MixpanelProfileService profileService = new MixpanelProfileService(bokunId, propertiesJson, isProdProfile);

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(profileService);
        Test.stopTest();

        // No specific assertion; check debug logs or use custom logging for validation
    }
}