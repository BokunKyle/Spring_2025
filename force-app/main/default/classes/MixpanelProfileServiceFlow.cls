public class MixpanelProfileServiceFlow {
    
    public class FlowOutput {
        @InvocableVariable
        public String resultMessage;  // This will store the message to pass back to the Flow
    }
    
    @InvocableMethod
    public static List<FlowOutput> MixpanelProfileUpdateFromFlow(List<FlowProfileInput> inputs) {
        List<FlowOutput> results = new List<FlowOutput>();
        
        for (FlowProfileInput input : inputs) {
            String bokunId = input.bokunId;
            Boolean isProdProfile = input.isProdProfile;
            
            if(isProdProfile != TRUE) { isProdProfile = FALSE; }
            
            // Prepare the properties map
            Map<String, Object> propertiesMap = new Map<String, Object>();

            // Add properties from the Flow input
            
            if (input.propertyKeys != null && input.propertyValues != null) {
                for (Integer i = 0; i < input.propertyKeys.size(); i++) {
                    if(input.propertyValues[i] != null)
                    {
                        propertiesMap.put(input.propertyKeys[i], input.propertyValues[i]);
                    }
                }
            }

            // Serialize the properties map into a JSON string
            String propertiesJson = JSON.serialize(propertiesMap);
            

            // Enqueue the MixpanelProfileService Queueable job for asynchronous callout
            System.enqueueJob(new MixpanelProfileService(bokunId, propertiesJson, isProdProfile));

            // Return success message to the Flow (since the job was enqueued)
            FlowOutput output = new FlowOutput();
            output.resultMessage = 'Mixpanel Profile Update enqueued successfully.';
            results.add(output);
        }
        
        return results;
    }
}