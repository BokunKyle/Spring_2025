trigger CaptureEmailContent on EmailMessage (before insert) {
    for (EmailMessage email : Trigger.new) {
        if (email.Subject != null && email.Subject.contains('Connect')) {
            // Log the body and other relevant fields
            System.debug('Email Subject: ' + email.Subject);
            System.debug('Email Body: ' + email.HtmlBody);
            System.debug('Recipient: ' + email.ToAddress);
        }
    }
}