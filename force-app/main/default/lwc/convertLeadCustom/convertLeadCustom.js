import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class convertLeadCustom extends NavigationMixin(LightningElement) {
    @api recordId; // Current Lead recordId passed automatically

    handleConvert() {
        // Navigate to the Screen Flow
        this[NavigationMixin.Navigate]({
            type: 'standard__flow',
            attributes: {
                flowApiName: 'Convert_Lead'
            },
            state: {
                recordId: this.recordId // Pass the current Lead ID to the Flow
            }
        });
    }
}