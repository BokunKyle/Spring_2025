import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = {
    Account: ['Account.Account_Notes__c'],
    Lead: ['Lead.Lead_Notes__c']
};

export default class customNotes extends LightningElement {
    @api recordId;
    @api objectApiName;
    notes = '';
    isLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields: '$computedFields' })
    wiredRecord({ error, data }) {
        if (data) {
            this.notes =
                this.objectApiName === 'Account'
                    ? data.fields.Account_Notes__c.value
                    : data.fields.Lead_Notes__c.value;
            this.isLoaded = true;
        } else if (error) {
            this.showToast('Error', 'Failed to load notes', 'error');
        }
    }

    get computedFields() {
        return this.objectApiName === 'Account' ? FIELDS.Account : FIELDS.Lead;
    }

    handleInput(event) {
        this.notes = event.target.value;
        this.adjustTextareaHeight(event.target);
    }

    handleSave() {
        const fields = {};
        fields['Id'] = this.recordId;
        fields[
            this.objectApiName === 'Account'
                ? 'Account_Notes__c'
                : 'Lead_Notes__c'
        ] = this.notes;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.showToast('Success', 'Notes updated successfully', 'success');
            })
            .catch(() => {
                this.showToast('Error', 'Failed to update notes', 'error');
            });
    }

    renderedCallback() {
        if (this.isLoaded) {
            this.adjustTextareaHeight();
        }
    }

    adjustTextareaHeight(textareaElement) {
        // Select the textarea element if not provided
        if (!textareaElement) {
            textareaElement = this.template.querySelector('textarea');
        }

        if (textareaElement) {
            textareaElement.style.height = 'auto'; // Reset height
            const minHeight = 3 * 16; // Approximate height for 3 lines (16px per line)
            const newHeight = Math.max(minHeight, textareaElement.scrollHeight);
            textareaElement.style.height = `${newHeight}px`; // Set to larger of minHeight or scrollHeight
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}