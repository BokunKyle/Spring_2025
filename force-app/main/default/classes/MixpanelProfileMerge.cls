public class MixpanelProfileMerge implements Queueable, Database.AllowsCallouts {

    private String acct1;
    private String acct2;
    private String projectId;
    private String authToken;

    // Constructor to pass parameters into the Queueable class
    public MixpanelProfileMerge(String acct1, String acct2, String projectId, String authToken) {
        this.acct1 = acct1;
        this.acct2 = acct2;
        this.projectId = projectId;
        this.authToken = authToken;
    }

    // The execute method where the callout happens
    public void execute(QueueableContext context) {
        
        // Ensure inputs are valid
        if (acct1 == null || acct1.trim() == '' || acct2 == null || acct2.trim() == '') {
            String errorMessage = 'MixpanelProfileMerge: Error - Account IDs are null or empty.';
            System.debug(errorMessage);
            ErrorLogger.logError(errorMessage, null, 'MixpanelProfileMerge', 0);
            return; // Exit if inputs are invalid
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String resultMessage;

        System.debug('MixpanelProfileMerge: Starting the profile merge process...');

        try {
            // Build the payload
            Map<String, Object> propertiesMap = new Map<String, Object>();
            propertiesMap.put('$distinct_ids', new List<String>{acct1, acct2});

            Map<String, Object> eventMap = new Map<String, Object>();
            eventMap.put('event', '$merge');
            eventMap.put('properties', propertiesMap);

            List<Map<String, Object>> payloadList = new List<Map<String, Object>>{ eventMap };
            String payloadJson = JSON.serialize(payloadList);

            // Set the endpoint and method
            String endpoint = 'https://api.mixpanel.com/import?strict=1&project_id=' + projectId;
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Basic ' + authToken);
            request.setBody(payloadJson);

            System.debug('MixpanelProfileMerge: Request body prepared: ' + payloadJson);

            // Perform the HTTP callout
            HttpResponse response = http.send(request);

            // Check the status and capture the response or error
            if (response.getStatusCode() != 200) {
                resultMessage = 'Error: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody();
                System.debug('MixpanelProfileMerge: Error occurred during the callout: ' + resultMessage);
                ErrorLogger.logError(resultMessage, null, 'MixpanelProfileMerge', 0);
            } else {
                resultMessage = 'Success: ' + response.getBody();
                System.debug('MixpanelProfileMerge: Success response received: ' + resultMessage);
            }
        } catch (Exception e) {
            resultMessage = 'Error during callout: ' + e.getMessage();
            System.debug('MixpanelProfileMerge: Exception occurred: ' + resultMessage);
            ErrorLogger.logError(resultMessage, e.getStackTraceString(), 'MixpanelProfileMerge', 0);
        }

        System.debug('MixpanelProfileMerge: Finished the profile merge process.');
    }
}