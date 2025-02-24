@IsTest
global class MixpanelHttpExceptionMock implements HttpCalloutMock {
    
    global HttpResponse respond(HttpRequest req) {
        // Simulate an exception by throwing one
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        res.setBody('{"status": "error"}');
        return res;
    }
}