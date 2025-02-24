@IsTest
public class UUIDGeneratorTest {

    // Test case to verify that a single UUID is generated
    @IsTest
    static void testGenerateSingleUUID() {
        // Create a list with a single dummy request (since @InvocableMethod requires a List input)
        List<String> requests = new List<String>{ 'Request1' };

        // Call the UUIDGenerator method to generate a single UUID
        List<String> generatedUUIDs = UUIDGenerator.generateUUIDForFlow(requests);

        // Verify that the UUID list is not null and contains exactly one entry
        Assert.isNotNull(generatedUUIDs, 'The list of generated UUIDs should not be null.');
        Assert.areEqual(1, generatedUUIDs.size(), 'The UUID list should contain exactly one UUID.');

        // Verify that the generated UUID is not null or empty
        String generatedUUID = generatedUUIDs[0];
        Assert.isNotNull(generatedUUID, 'The generated UUID should not be null.');
        Assert.areEqual(36, generatedUUID.length(), 'The UUID should be 36 characters long (including hyphens).');
    }

    // Test case to verify that multiple UUIDs can be generated
    @IsTest
    static void testGenerateMultipleUUIDs() {
        // Create a list with multiple dummy requests
        List<String> requests = new List<String>{ 'Request1', 'Request2', 'Request3' };

        // Call the UUIDGenerator method to generate multiple UUIDs
        List<String> generatedUUIDs = UUIDGenerator.generateUUIDForFlow(requests);

        // Verify that the UUID list is not null and contains the correct number of entries
        Assert.isNotNull(generatedUUIDs, 'The list of generated UUIDs should not be null.');
        Assert.areEqual(3, generatedUUIDs.size(), 'The UUID list should contain exactly 3 UUIDs.');

        // Verify that each generated UUID is not null, empty, and properly formatted
        for (String uuid : generatedUUIDs) {
            Assert.isNotNull(uuid, 'The generated UUID should not be null.');
            Assert.areEqual(36, uuid.length(), 'Each UUID should be 36 characters long (including hyphens).');
        }

        // Additional check to ensure the UUIDs are unique
        Set<String> uniqueUUIDs = new Set<String>(generatedUUIDs);
        Assert.areEqual(3, uniqueUUIDs.size(), 'The generated UUIDs should all be unique.');
    }
}