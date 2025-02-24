@IsTest
global class MixpanelHttpMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200); // Simulating a successful response
        res.setBody('{"status": "ok"}'); // Body content to verify in the test
        return res;
    }
}