public class FlowProfileInput {
    @AuraEnabled
    @InvocableVariable    
    public String bokunId;    // The ID of the record (bokun_id)
    
    @AuraEnabled
    @InvocableVariable
    public List<String> propertyKeys;  // List of property keys (must be a list of primitives)
    
    @AuraEnabled
    @InvocableVariable
    public List<String> propertyValues;  // List of property values (must be a list of primitives)
    
    @AuraEnabled
    @InvocableVariable
    public Boolean isProdProfile;  // Must be explicitly passed as true to go to production, otherwise Mixpanel Dev
    
}