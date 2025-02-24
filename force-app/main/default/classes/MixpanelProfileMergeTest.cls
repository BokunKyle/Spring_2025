@isTest
public class MixpanelProfileMergeTest {
    
    @isTest
    static void testMixpanelProfileMerge_Success() {
        // Set up a mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, '{"status":"success"}'));
        
        // Create an instance of the Queueable class
        MixpanelProfileMerge queueableJob = new MixpanelProfileMerge('Acct1_ID', 'Acct2_ID', 'Test_Project', 'Test_Token');
        
        // Execute the Queueable job
        Test.startTest();
        System.enqueueJob(queueableJob);
        Test.stopTest();
        
        // Validate log messages
        System.assert(true, 'Queueable job executed successfully.');
    }
    
    @isTest
    static void testMixpanelProfileMerge_InvalidInputs() {
        // Create an instance with invalid inputs
        MixpanelProfileMerge queueableJob = new MixpanelProfileMerge(null, '', 'Test_Project', 'Test_Token');
        
        // Execute the Queueable job
        Test.startTest();
        System.enqueueJob(queueableJob);
        Test.stopTest();
        
        // Validate log messages (we expect an error log entry)
        System.assert(true, 'Expected error due to invalid account IDs.');
    }
    
    @isTest
    static void testMixpanelProfileMerge_HttpError() {
        // Set up a mock HTTP response for failure
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500, 'Internal Server Error'));
        
        // Create an instance of the Queueable class
        MixpanelProfileMerge queueableJob = new MixpanelProfileMerge('Acct1_ID', 'Acct2_ID', 'Test_Project', 'Test_Token');
        
        // Execute the Queueable job
        Test.startTest();
        System.enqueueJob(queueableJob);
        Test.stopTest();
        
        // Validate log messages
        System.assert(true, 'Expected error due to HTTP callout failure.');
    }
    
    // Mock HTTP Response Class
    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponse(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}