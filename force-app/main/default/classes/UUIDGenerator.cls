public class UUIDGenerator {

    @InvocableMethod(label='Generate UUID')
    public static List<String> generateUUIDForFlow(List<String> requests) {
        List<String> uuids = new List<String>();
        
        // Loop through the input requests and generate a UUID for each request
        for (String request : requests) {
            uuids.add(UUID.randomUUID().toString());
        }

        return uuids;
    }
}