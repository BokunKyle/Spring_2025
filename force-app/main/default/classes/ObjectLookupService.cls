public class ObjectLookupService {

    // Define the input and output classes for Flow compatibility
    public class Output {
        @InvocableVariable
        public String resultValue;
    }

    @InvocableMethod(label='Get Company or Mixpanel ID' description='Returns Company_Id__c or Mixpanel_Distinct_ID__c based on the input ID')
    public static List<Output> getMixpanelId(List<Id> inputIds) {
        List<Output> results = new List<Output>();

        for (Id inputId : inputIds) {
            Output output = new Output();

            if (inputId == null) {
                output.resultValue = null;
                System.debug('Input ID is null, skipping.');
                ErrorLogger.logError('Input ID is null', null, 'ObjectLookupService', 0);
                results.add(output);
                continue;
            }

            String objectType = inputId.getSObjectType().getDescribe().getName();
            System.debug('Processing ID: ' + inputId + ' of type: ' + objectType);

            try {
                if (objectType == 'Account') {
                    // Account: Use Company_Id__c
                    Account acc = [SELECT Company_Id__c FROM Account WHERE Id = :inputId LIMIT 1];
                    output.resultValue = acc.Company_Id__c;
                    System.debug('Account Company_Id__c: ' + acc.Company_Id__c);
                } else if (objectType == 'Lead') {
                    // Lead: Use Mixpanel_Distinct_Id__c
                    Lead lead = [SELECT Mixpanel_Distinct_ID__c FROM Lead WHERE Id = :inputId LIMIT 1];
                    output.resultValue = lead.Mixpanel_Distinct_ID__c;
                    System.debug('Lead Mixpanel_Distinct_ID__c: ' + lead.Mixpanel_Distinct_ID__c);
                } else {
                    // Other object: Evaluate relationships
                    output.resultValue = evaluateRelationships(inputId, 2);
                }
            } catch (Exception e) {
                String errorMessage = 'Error processing ID: ' + inputId + '. Error: ' + e.getMessage();
                System.debug(errorMessage);
                ErrorLogger.logError(errorMessage, e.getStackTraceString(), 'ObjectLookupService', 0);
                output.resultValue = null;
            }

            results.add(output);
        }

        System.debug('Final results: ' + results);
        return results;
    }
    
    private static String evaluateRelationships(Id inputId, Integer remainingLevels) {
        if (remainingLevels == 0 || inputId == null) {
            String errorMessage = 'Maximum recursion depth reached or input ID is null.';
            System.debug(errorMessage);
            ErrorLogger.logError(errorMessage, null, 'ObjectLookupService', 0);
            return null;
        }
    
        System.debug('Evaluating relationships for ID: ' + inputId + ', Remaining Levels: ' + remainingLevels);

        try {
            String objectType = inputId.getSObjectType().getDescribe().getName();
            System.debug('Object Type: ' + objectType);
    
            // Check if the current inputId has a valid Mixpanel or Company ID
            String resolvedId = evaluateMixpanelOrCompanyId(inputId);
            if (resolvedId != null) {
                System.debug('Resolved ID: ' + resolvedId);
                return resolvedId;
            }
    
            // Prepare the query dynamically based on object type and supported fields
            DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectType).getDescribe();
            String query = 'SELECT ';
            List<String> fieldsToQuery = new List<String>();
    
            if (objectType == 'Contact') {
                if (describeResult.fields.getMap().containsKey('AccountId')) {
                    fieldsToQuery.add('AccountId');
                }
                if (describeResult.fields.getMap().containsKey('ReportsToId')) {
                    fieldsToQuery.add('ReportsToId');
                }
            } else {
                if (describeResult.fields.getMap().containsKey('WhatId')) {
                    fieldsToQuery.add('WhatId');
                }
                if (describeResult.fields.getMap().containsKey('WhoId')) {
                    fieldsToQuery.add('WhoId');
                }
                if (describeResult.fields.getMap().containsKey('AccountId')) {
                    fieldsToQuery.add('AccountId');
                }
            }
    
            if (fieldsToQuery.isEmpty()) {
                String errorMessage = 'No relevant fields to query for object: ' + objectType;
                System.debug(errorMessage);
                ErrorLogger.logError(errorMessage, null, 'ObjectLookupService', 0);
                return null;
            }
    
            query += String.join(fieldsToQuery, ', ') + ' FROM ' + objectType + ' WHERE Id = :inputId LIMIT 1';
    
            SObject record = Database.query(query);
    
            // Determine next ID to evaluate
            Id nextId = null;
            if (objectType == 'Contact') {
                nextId = record.get('AccountId') != null ? (Id) record.get('AccountId') :
                         record.get('ReportsToId') != null ? (Id) record.get('ReportsToId') : null;
            } 
            else if (objectType == 'Opportunity') {
                nextId = record.get('AccountId') != null ? (Id) record.get('AccountId') : null;
            }            
            else {
                nextId = record.get('WhatId') != null ? (Id) record.get('WhatId') :
                         record.get('WhoId') != null ? (Id) record.get('WhoId') : null;
            }
    
            if (nextId != null) {
                System.debug('Next ID to evaluate: ' + nextId);
                return evaluateRelationships(nextId, remainingLevels - 1);
            }
        } catch (Exception e) {
            String errorMessage = 'Error evaluating relationships for ID: ' + inputId + '. Error: ' + e.getMessage();
            System.debug(errorMessage);
            ErrorLogger.logError(errorMessage, e.getStackTraceString(), 'ObjectLookupService', 0);
        }
    
        return null;
    }

    private static String evaluateMixpanelOrCompanyId(Id objectId) {
        try {
            String objectType = objectId.getSObjectType().getDescribe().getName();
    
            if (objectType == 'Account') {
                Account acc = [SELECT Company_Id__c FROM Account WHERE Id = :objectId LIMIT 1];
                return acc.Company_Id__c;
            } else if (objectType == 'Contact') {
                Contact con = [SELECT Account.Company_Id__c FROM Contact WHERE Id = :objectId LIMIT 1];
                return con.Account != null ? con.Account.Company_Id__c : null;
            } else if (objectType == 'Lead') {
                Lead lead = [SELECT Mixpanel_Distinct_ID__c FROM Lead WHERE Id = :objectId LIMIT 1];
                return lead.Mixpanel_Distinct_ID__c;
            }
        } catch (Exception e) {
            String errorMessage = 'Error resolving Mixpanel/Company ID for object ID: ' + objectId + '. Error: ' + e.getMessage();
            System.debug(errorMessage);
            ErrorLogger.logError(errorMessage, e.getStackTraceString(), 'ObjectLookupService', 0);
        }
        return null;
    }
}