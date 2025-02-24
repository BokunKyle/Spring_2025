public class MixpanelEventService implements Queueable, Database.AllowsCallouts {

    private String eventName;
    private String bokunId;
    private String propertiesJson;
    private Boolean isProdEvent;
    private String mixpanelToken;

    // Constructor to pass parameters into the Queueable class
    public MixpanelEventService(String eventName, String bokunId, String propertiesJson, Boolean isProdEvent) {
        this.eventName = eventName;
        this.bokunId = bokunId;
        this.propertiesJson = propertiesJson;
        this.isProdEvent = isProdEvent;
        
        // Ensure isProdEvent is never null
        if (isProdEvent == null) {
            isProdEvent = false;
        }
    }

    // The execute method where the callout happens
    public void execute(QueueableContext context) {
        
        // Check if bokunId is not null and not an empty string
        if (bokunId == null || bokunId.trim() == '') {
            String errorMessage = 'MixpanelEventService: Error - bokunId is null or empty.';
            System.debug(errorMessage);
            ErrorLogger.logError(errorMessage, null, 'MixpanelEventService', 0);
            return; // Exit the method if bokunId is invalid
        }
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Long currentTimestampMillis = System.now().getTime();
        String resultMessage;

        System.debug('MixpanelEventService: Starting the Mixpanel event tracking process...');

        try {
            // Deserialize the properties JSON back into a map
            Map<String, Object> propertiesMap = (Map<String, Object>) JSON.deserializeUntyped(propertiesJson);

            System.debug('MixpanelEventService: Properties deserialized: ' + propertiesMap);

            // Generate a unique insert ID
            String insertId = UUID.randomUUID().toString();

            // Get the Mixpanel token from TokenUtility
            if (isProdEvent) {
                mixpanelToken = TokenUtility.getMpProdToken();
                System.debug('Using production Mixpanel token.');
            } else {
                mixpanelToken = TokenUtility.getMpDevToken();
                System.debug('Using development Mixpanel token.');
            }

            // Add required fields to properties, including the Mixpanel token
            propertiesMap.put('token', mixpanelToken);   // Add the token
            propertiesMap.put('distinct_id', bokunId);
            propertiesMap.put('time', currentTimestampMillis);
            propertiesMap.put('$insert_id', insertId);

            System.debug('MixpanelEventService: Properties after adding required fields: ' + propertiesMap);

            // Convert properties map back to JSON
            String updatedPropertiesJson = JSON.serialize(propertiesMap);

            // Set the endpoint and method
            request.setEndpoint('https://api.mixpanel.com/track?ip=0');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');

            // Set the body with the event name and updated properties
            String body = '[{"properties": ' + updatedPropertiesJson + ', "event": "' + eventName + '"}]';
            request.setBody(body);

            System.debug('MixpanelEventService: Request body prepared: ' + body);

            // Perform the HTTP callout
            HttpResponse response = http.send(request);
            
            // Check the status and capture the response or error
            if (response.getStatusCode() != 200) {
                resultMessage = 'Error: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody();
                System.debug('MixpanelEventService: Error occurred during the callout: ' + resultMessage);
                ErrorLogger.logError(resultMessage, null, 'MixpanelEventService', 0);
            } else {
                resultMessage = 'Success: ' + response.getBody();
                System.debug('MixpanelEventService: Success response received: ' + resultMessage);
            }
        } catch (Exception e) {
            resultMessage = 'Error during callout: ' + e.getMessage();
            System.debug('MixpanelEventService: Exception occurred: ' + resultMessage);
            ErrorLogger.logError(e.getMessage(), e.getStackTraceString(), 'MixpanelEventService', 0);
        }

        System.debug('MixpanelEventService: Finished the Mixpanel event tracking process.');
    }
}