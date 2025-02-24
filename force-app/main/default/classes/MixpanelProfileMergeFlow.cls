public class MixpanelProfileMergeFlow {

    public class FlowInput {
        @InvocableVariable(required=true)
        public String acct1; // Lead Company_Id_Text__c

        @InvocableVariable(required=true)
        public String acct2; // Account Company_ID_Text__c

        @InvocableVariable(required=false)
        public Boolean isProd; // Boolean to decide if the call is made to Production or Development
    }

    public class FlowOutput {
        @InvocableVariable
        public String resultMessage; // Message to pass back to the Flow
    }

    @InvocableMethod(label='Merge Mixpanel Profiles' description='Merge two Mixpanel profiles based on provided distinct IDs.')
    public static List<FlowOutput> mergeProfilesFromFlow(List<FlowInput> inputs) {
        List<FlowOutput> results = new List<FlowOutput>();

        for (FlowInput input : inputs) {
            String acct1 = input.acct1;
            String acct2 = input.acct2;
            Boolean isProd = input.isProd != null && input.isProd; // Default to false if not provided

            // Fetch appropriate Mixpanel Project ID and Service Account Token
            String projectId = isProd ? TokenUtility.getMpProdProjectID() : TokenUtility.getMpDevProjectID();
            String authToken = TokenUtility.getMpServiceAcct();

            // Enqueue the MixpanelProfileMerge Queueable job for asynchronous callout
            System.enqueueJob(new MixpanelProfileMerge(acct1, acct2, projectId, authToken));

            // Return success message to the Flow (since the job was enqueued)
            FlowOutput output = new FlowOutput();
            output.resultMessage = 'Mixpanel profile merge enqueued successfully.';
            results.add(output);
        }

        return results;
    }
}