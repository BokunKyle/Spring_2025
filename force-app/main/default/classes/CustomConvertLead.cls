public class CustomConvertLead {

    // Class to hold input parameters
    public class ConvertLeadInput {
        @InvocableVariable(required=true)
        public Id leadId;     // The ID of the Lead to be converted
        
        @InvocableVariable(required=true)
        public Id accountId;  // The ID of the Account to convert the Lead to
    }

    // Class to hold output parameters
    public class ConvertLeadOutput {
        @InvocableVariable
        public String resultMessage; // Success or failure message
    }

    // Method exposed to Flow
    @InvocableMethod(label='Convert Lead' description='Converts a lead to an account/contact/opportunity')
    public static List<ConvertLeadOutput> convertLeadFromFlow(List<ConvertLeadInput> inputs) {
        List<ConvertLeadOutput> results = new List<ConvertLeadOutput>();

        for (ConvertLeadInput input : inputs) {
            ConvertLeadOutput output = new ConvertLeadOutput();

            try {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(input.leadId);
                lc.setAccountId(input.accountId);
                lc.setDoNotCreateOpportunity(true);
                
                // Dynamically fetch the converted status
                String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1].MasterLabel;
                lc.setConvertedStatus(convertedStatus);

                // Convert the lead
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                
                if (lcr.isSuccess()) {
                    output.resultMessage = 'Lead converted successfully.';
                } else {
                    String errorMessage = 'Lead conversion failed for Lead ID ' + input.leadId;
                    if (lcr.getErrors().size() > 0) {
                        errorMessage += ': ' + lcr.getErrors()[0].getMessage();
                    }
                    // Log the error using ErrorLogger
                    ErrorLogger.logError(errorMessage, null, 'CustomConvertLead', -1);
                    output.resultMessage = errorMessage;
                }
            } catch (Exception e) {
                String errorMessage = 'An error occurred during lead conversion for Lead ID ' + input.leadId + ': ' + e.getMessage();
                
                // Log the error using ErrorLogger
                ErrorLogger.logError(errorMessage, e.getStackTraceString(), 'CustomConvertLead', -1);

                output.resultMessage = errorMessage;
            }

            results.add(output);
        }

        return results;
    }
}