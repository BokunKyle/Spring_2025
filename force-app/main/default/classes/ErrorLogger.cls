public class ErrorLogger {
    /**
     * Logs an error to the custom Error Log object.
     * @param errorMessage The error message to log.
     * @param stackTrace The stack trace or additional details (optional).
     * @param apexClass The name of the Apex class where the error occurred.
     * @param lineNumber The line number of the error (if available).
     */
    public static void logError(String errorMessage, String stackTrace, String apexClass, Integer lineNumber) {
        try {
            // Create a new Error Log record
            Error_Log__c errorLog = new Error_Log__c(
                Message__c = errorMessage,
                Stack_Trace__c = stackTrace,
                Apex_Class__c = apexClass,
                Line_Number__c = lineNumber,
                Occurred_On__c = System.now()
            );

            // Insert the record into Salesforce
            insert errorLog;

        } catch (Exception e) {
            // Handle errors during the logging process to avoid cascading failures
            System.debug('Error while logging the error: ' + e.getMessage());
        }
    }
}