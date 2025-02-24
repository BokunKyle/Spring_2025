public class TokenUtility {
    // Static variable to store the tokens
    private static final String MIXPANEL_DEV = '53707dbec14fa0e21dfc867086baa74d';
    private static final String MIXPANEL_PROD = 'a5214d3866afc6b9b43bfe28ca273764';
    private static final String MIXPANEL_DEV_PROJECT_ID = '1938167';
    private static final String MIXPANEL_PROD_PROJECT_ID = '874345';
    private static final String MIXPANEL_ENCRYPTED_SERVICE_ACCOUNT = 'U2FsZXNmb3JjZS41YzA4MTEubXAtc2VydmljZS1hY2NvdW50OmdYSUF5QmprTXpXbFBFN0hmWFRVcjY3Z1RxelZOUVdK';

    // Optional: Static method to return the tokens (if needed)
    public static String getMpDevToken() {
        return MIXPANEL_DEV;
    }
    public static String getMpProdToken() {
        return MIXPANEL_PROD;
    }
    public static String getMpServiceAcct() { 
        return MIXPANEL_ENCRYPTED_SERVICE_ACCOUNT;
    }
    public static String getMpDevProjectID() {
        return MIXPANEL_DEV_PROJECT_ID;
    }
    public static String getMpProdProjectID() {
        return MIXPANEL_PROD_PROJECT_ID;
    }
}