import { LightningElement, api } from 'lwc';

export default class RefreshRecord extends LightningElement {
    @api invoke() {
        // Force refresh of the current page
        eval("$A.get('e.force:refreshView').fire();");
    }
}