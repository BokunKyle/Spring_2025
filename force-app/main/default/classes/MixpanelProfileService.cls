public class MixpanelProfileService implements Queueable, Database.AllowsCallouts {

    private String bokunId;
    private String propertiesJson;
    private Boolean isProdProfile;
    private String mixpanelToken;

    // Constructor to pass parameters into the Queueable class
    public MixpanelProfileService(String bokunId, String propertiesJson, Boolean isProdProfile) {
        this.bokunId = bokunId;
        this.propertiesJson = propertiesJson;
        this.isProdProfile = isProdProfile;
        
        // Ensure isProdProfile is never null
        if (isProdProfile == null) {
            isProdProfile = false;
        }
    }

    // The execute method where the callout happens
    public void execute(QueueableContext context) {
        
        // Check if bokunId is not null and not an empty string
        if (bokunId == null || bokunId.trim() == '') {
            String errorMessage = 'MixpanelProfileService: Error - bokunId is null or empty.';
            System.debug(errorMessage);
            ErrorLogger.logError(errorMessage, null, 'MixpanelProfileService', 0);
            return; // Exit the method if bokunId is invalid
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String resultMessage;

        System.debug('MixpanelProfileService: Starting the Mixpanel profile update process...');

        try {
            // Check if the propertiesJson string is valid JSON and can be deserialized
            if (propertiesJson == null || propertiesJson.trim() == '') {
                String errorMessage = 'MixpanelProfileService: Error - propertiesJson is null or empty.';
                System.debug(errorMessage);
                ErrorLogger.logError(errorMessage, null, 'MixpanelProfileService', 0);
                return;
            }

            // Deserialize the properties JSON back into a map
            Map<String, Object> propertiesMap;
            try {
                propertiesMap = (Map<String, Object>) JSON.deserializeUntyped(propertiesJson);
                System.debug('MixpanelProfileService: Properties deserialized: ' + propertiesMap);
            } catch (JSONException e) {
                String errorMessage = 'MixpanelProfileService: Error - Invalid JSON format.';
                System.debug(errorMessage);
                ErrorLogger.logError(errorMessage, e.getStackTraceString(), 'MixpanelProfileService', 0);
                return;
            }

            // Get the Mixpanel token from TokenUtility
            if (isProdProfile) {
                mixpanelToken = TokenUtility.getMpProdToken();
                System.debug('Using production Mixpanel token.');
            } else {
                mixpanelToken = TokenUtility.getMpDevToken();
                System.debug('Using development Mixpanel token.');
            }

            // Build the final JSON structure
            Map<String, Object> finalPayload = new Map<String, Object>();
            finalPayload.put('$token', mixpanelToken);
            finalPayload.put('$distinct_id', bokunId);
            finalPayload.put('$set', propertiesMap); // Embed properties under the $set key

            System.debug('MixpanelProfileService: Final payload: ' + finalPayload);

            // Convert final payload map back to JSON
            String finalPayloadJson = JSON.serialize(finalPayload);

            // Set the endpoint and method
            request.setEndpoint('https://api.mixpanel.com/engage?ip=0&strict=1&verbose=1#profile-set');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');

            // Set the body with the final payload
            String body = '[' + finalPayloadJson + ']';
            request.setBody(body);

            System.debug('MixpanelProfileService: Request body prepared: ' + body);

            // Perform the HTTP callout
            HttpResponse response = http.send(request);

            System.debug('After HTTP callout, status code: ' + response.getStatusCode());

            // Check the status and capture the response or error
            if (response.getStatusCode() != 200) {
                resultMessage = 'Error: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody();
                System.debug('MixpanelProfileService: Error occurred during the callout: ' + resultMessage);
                ErrorLogger.logError(resultMessage, null, 'MixpanelProfileService', 0);
            } else {
                resultMessage = 'Success: ' + response.getBody();
                System.debug('MixpanelProfileService: Success response received: ' + resultMessage);
            }
        } catch (Exception e) {
            resultMessage = 'Error during callout: ' + e.getMessage();
            System.debug('MixpanelProfileService: Exception occurred: ' + resultMessage);
            ErrorLogger.logError(resultMessage, e.getStackTraceString(), 'MixpanelProfileService', 0);
        }

        System.debug('MixpanelProfileService: Finished the Mixpanel profile update process.');
    }
}