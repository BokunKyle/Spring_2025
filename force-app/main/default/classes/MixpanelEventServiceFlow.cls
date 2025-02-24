public class MixpanelEventServiceFlow {

    public class FlowOutput {
        @InvocableVariable
        public String resultMessage;  // This will store the message to pass back to the Flow
    }
    
    @InvocableMethod
    public static List<FlowOutput> trackMixpanelEventFromFlow(List<FlowEventInput> inputs) {
        List<FlowOutput> results = new List<FlowOutput>();

        try {
            // Fetch valid event names from custom metadata
            List<String> validEventNames = new List<String>();
            for (Mixpanel_Events__mdt eventNameRecord : [SELECT MasterLabel FROM Mixpanel_Events__mdt]) {
                validEventNames.add(eventNameRecord.MasterLabel);
            }
            
            for (FlowEventInput input : inputs) {
                String bokunId = input.bokunId;
                String eventName = input.eventName;
                Boolean isProdEvent = input.isProdEvent;

                if (isProdEvent != TRUE) { isProdEvent = FALSE; }

                FlowOutput output = new FlowOutput();
                
                // Validate event name
                if (!validEventNames.contains(eventName)) {
                    String errorMessage = 'Invalid event name: ' + eventName + '. Allowed values are: ' + String.join(validEventNames, ', ');
                    System.debug(errorMessage);
                    ErrorLogger.logError(errorMessage, null, 'MixpanelEventServiceFlow', 0);
                    output.resultMessage = errorMessage;
                    results.add(output);
                    continue;
                }
                
                // Validate bokunId
                if (bokunId == null || bokunId.trim() == '') {
                    String errorMessage = 'Invalid bokunId: bokunId cannot be null or empty.';
                    System.debug(errorMessage);
                    ErrorLogger.logError(errorMessage, null, 'MixpanelEventServiceFlow', 0);
                    output.resultMessage = errorMessage;
                    results.add(output);
                    continue;
                }

                // Prepare the properties map
                Map<String, Object> propertiesMap = new Map<String, Object>();

                try {
                    // Add properties from the Flow input
                    if (input.propertyKeys != null && input.propertyValues != null) {
                        for (Integer i = 0; i < input.propertyKeys.size(); i++) {
                            propertiesMap.put(input.propertyKeys[i], input.propertyValues[i]);
                        }
                    }

                    // Serialize the properties map into a JSON string
                    String propertiesJson = JSON.serialize(propertiesMap);

                    // Enqueue the MixpanelService Queueable job for asynchronous callout
                    System.enqueueJob(new MixpanelEventService(eventName, bokunId, propertiesJson, isProdEvent));
                    output.resultMessage = 'Mixpanel event enqueued successfully.';
                } catch (Exception e) {
                    String errorMessage = 'Error preparing Mixpanel event: ' + e.getMessage();
                    System.debug(errorMessage);
                    ErrorLogger.logError(errorMessage, e.getStackTraceString(), 'MixpanelEventServiceFlow', 0);
                    output.resultMessage = errorMessage;
                }

                results.add(output);
            }
        } catch (Exception e) {
            String errorMessage = 'Unhandled error in trackMixpanelEventFromFlow: ' + e.getMessage();
            System.debug(errorMessage);
            ErrorLogger.logError(errorMessage, e.getStackTraceString(), 'MixpanelEventServiceFlow', 0);
            FlowOutput output = new FlowOutput();
            output.resultMessage = errorMessage;
            results.add(output);
        }

        return results;
    }
}