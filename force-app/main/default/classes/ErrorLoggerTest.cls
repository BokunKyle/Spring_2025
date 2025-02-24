@isTest
public class ErrorLoggerTest {
    @isTest
    static void testErrorLogging() {
        // Call the error logging utility
        try {
            // Simulate an exception
            Integer result = 10 / 0;
        } catch (Exception e) {
            // Log the exception using the ErrorLogger class
            ErrorLogger.logError(
                e.getMessage(),
                e.getStackTraceString(),
                'ErrorLoggerTest',
                15 // Example line number where the error occurred
            );
        }

        // Verify that the error log was created
        Error_Log__c[] logs = [SELECT Message__c, Stack_Trace__c, Apex_Class__c, Line_Number__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(), 'Error log record should be created.');
        System.assertEquals('ErrorLoggerTest', logs[0].Apex_Class__c, 'Class name should match.');
    }
}