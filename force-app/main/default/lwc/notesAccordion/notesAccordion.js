import { LightningElement, api } from 'lwc';

export default class notesAccordion extends LightningElement {
    @api title = 'Notes'; // Accordion title
    @api recordId; // Record ID to pass to customNotes
    @api objectApiName; // Object API name to pass to customNotes
    isOpen = true; // Tracks whether the accordion is open

    get iconName() {
        return this.isOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleAccordion() {
        this.isOpen = !this.isOpen;
    }
}