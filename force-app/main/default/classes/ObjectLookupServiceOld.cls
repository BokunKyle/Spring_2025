public class ObjectLookupServiceOld {

    // Define the input and output classes for Flow compatibility
    public class Output {
        @InvocableVariable
        public String resultValue;
    }

    @InvocableMethod(label='Get Company or Mixpanel ID' description='Returns Company_Id__c or Mixpanel_Distinct_ID__c based on the input ID')
    public static List<Output> getMixpanelId(List<Id> inputIds) {
        List<Output> results = new List<Output>();

        // Loop through all inputIds provided by Flow
        for (Id inputId : inputIds) {
            Output output = new Output();
            
            // Check if the inputId is null
            if (inputId == null) {
                output.resultValue = 'Invalid input_id';
                results.add(output);
                continue;
            }

            // Get the SObjectType from the inputId
            SObjectType inputSObjectType = inputId.getSObjectType();
            DescribeSObjectResult describeResult = inputSObjectType.getDescribe();
            String inputType = describeResult.getName();

            System.debug('Processing object type: ' + inputType);

            // Get the field map from the object description
            Map<String, SObjectField> fieldsMap = describeResult.fields.getMap();
            
            // Check if the object contains the fields
            Boolean hasCompanyIdField = fieldsMap.containsKey('Company_Id__c');
            Boolean hasMixpanelIdField = fieldsMap.containsKey('Mixpanel_Distinct_ID__c');

            System.debug('Has Company_Id__c: ' + hasCompanyIdField);
            System.debug('Has Mixpanel_Distinct_ID__c: ' + hasMixpanelIdField);

            // If neither field exists, return an appropriate message
            if (!hasCompanyIdField && !hasMixpanelIdField) {
                output.resultValue = 'Neither Company_Id__c nor Mixpanel_Distinct_ID__c exists on this object';
                results.add(output);
                continue;
            }

            // Build the dynamic SOQL query only for the fields that exist on the object
            List<String> selectedFields = new List<String>();
            if (hasCompanyIdField) {
                selectedFields.add('Company_Id__c');
            }
            if (hasMixpanelIdField) {
                selectedFields.add('Mixpanel_Distinct_ID__c');
            }

            // Create the dynamic query
            String query = 'SELECT ' + String.join(selectedFields, ',') + ' FROM ' + inputType + ' WHERE Id = :inputId LIMIT 1';
            
            System.debug('Executing query: ' + query);

            // Execute the dynamic query and cast the result as a generic SObject
            SObject record = Database.query(query);
        
            System.debug('Record found: ' + record);
            
            Integer mplength = 0;
            
            if (hasMixpanelIdField) {
            // Assuming 'record' is a map or similar structure containing the value
            String mixpanelId = (String) record.get('Mixpanel_Distinct_ID__c');

            // Check for null to avoid a NullPointerException
            mplength = (mixpanelId != null) ? mixpanelId.length() : 0;
            
            // Now 'mplength' contains the length of the string or 0 if it's null
            }
            
            
            // Check and return Company_Id__c if populated, otherwise Mixpanel_Distinct_ID__c
            if (hasCompanyIdField && record.get('Company_Id__c') != null && record.get('Company_Id__c') != '0') {
                System.debug('Company_Id__c: ' + record.get('Company_Id__c'));
                output.resultValue = (String) record.get('Company_Id__c');
            } else if (hasMixpanelIdField && mplength > 1 ) {
                System.debug('Mixpanel_Distinct_ID__c: ' + record.get('Mixpanel_Distinct_ID__c'));
                output.resultValue = (String) record.get('Mixpanel_Distinct_ID__c');
            } else {
                output.resultValue = 'No relevant data found in Company_Id__c or Mixpanel_Distinct_ID__c';
            }

            // Add result to the list
            results.add(output);
        }
        system.debug(results);
        return results;
    }
}