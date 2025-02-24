@IsTest
public class TokenUtilityTest {

    @IsTest
    static void testGetMpDevTokenNotNull() {
        // Test that the Dev Token is not null
        String devToken = TokenUtility.getMpDevToken();
        Assert.isNotNull(devToken, 'The Dev Token should not be null.');
    }

    @IsTest
    static void testGetMpProdTokenNotNull() {
        // Test that the Prod Token is not null
        String prodToken = TokenUtility.getMpProdToken();
        Assert.isNotNull(prodToken, 'The Prod Token should not be null.');
    }

    @IsTest
    static void testGetMpServiceAcctNotNull() {
        // Test that the Service Account Token is not null
        String serviceAcct = TokenUtility.getMpServiceAcct();
        Assert.isNotNull(serviceAcct, 'The Service Account Token should not be null.');
    }

    @IsTest
    static void testMpDevProjectIDNotNull() {
        // Test that the Dev project ID is not null
        String dpid = TokenUtility.getMpDevProjectID();
        Assert.isNotNull(dpid, 'The Dev project ID should not be null.');
    }
    
    @IsTest
    static void testMpProdProjectIDNotNull() {
        // Test that the Prod project ID is not null
        String ppid = TokenUtility.getMpProdProjectID();
        Assert.isNotNull(ppid, 'The Prod project ID should not be null.');
    }
}