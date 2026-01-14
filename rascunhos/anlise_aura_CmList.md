
# exemplo do doc analise

## js

```js
import { LightningElement, wire, track } from 'lwc';
import getCMRecords from '@salesforce/apex/CMController.getCMRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'CM ID', fieldName: 'cmId', type: 'text' },
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Owner Name', fieldName: 'ownerName', type: 'text' }
];

export default class CmList extends LightningElement {
    @track columns = COLUMNS;
    @track cmData = [];
    @track error;
    @track recordIdsSemicolon = '';
    @track isLoading = false;

    changeHandler(event) {
        this.recordIdsSemicolon = event.target.value;
    }

    handleSearch() {
        if (!this.recordIdsSemicolon) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Enter semicolon-separated CM Ids (e.g., id1;id2;id3)',
                variant: 'error'
            }));
            return;
        }

        this.isLoading = true;
        this.error = undefined;
        getCMRecords({ recordIdsSemicolon: this.recordIdsSemicolon })
            .then(result => {
                this.cmData = result;
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: `${result.length} CM records loaded.`,
                    variant: 'success'
                }));
            })
            .catch(error => {
                this.error = error.body?.message || error.message;
                this.cmData = [];
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error loading CM records',
                    message: this.error,
                    variant: 'error'
                }));
            });
    }
}
```

### js-meta
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>61.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
    </targets>
</LightningComponentBundle>
```

## HTML

```html
<template>
    <lightning-card title="CM Records Lookup" icon-name="standard:account">
        <div class="slds-m-around_medium">
            <!-- Input for semicolon-separated Ids -->
            <div class="slds-form-element slds-m-bottom_medium">
                <label class="slds-form-element__label" for="idsInput">CM Record Ids (semicolon-separated):</label>
                <div class="slds-form-element__control">
                    <lightning-input
                        type="text"
                        label="Ids"
                        value={recordIdsSemicolon}
                        onchange={changeHandler}
                        placeholder="a01xx000000001A;a01xx000000001B;a01xx000000001C">
                    </lightning-input>
                </div>
            </div>

            <!-- Search Button -->
            <lightning-button
                label="Search CM Records"
                variant="brand"
                onclick={handleSearch}
                disabled={isLoading}>
            </lightning-button>

            <!-- Loading Spinner -->
            <template if:true={isLoading}>
                <div class="slds-align_absolute-center slds-p-top_large">
                    <lightning-spinner alternative-text="Loading CM records..."></lightning-spinner>
                </div>
            </template>

            <!-- Error Message -->
            <template if:true={error}>
                <div class="slds-notify slds-notify_alert slds-theme_error slds-m-top_medium">
                    <span class="slds-assistive-text">Error</span>
                    <h2>Error: {error}</h2>
                </div>
            </template>

            <!-- Data Table -->
            <template if:true={cmData}>
                <div class="slds-m-top_medium">
                    <lightning-datatable
                        key-field="cmId"
                        data={cmData}
                        columns={columns}
                        hide-checkbox-column>
                    </lightning-datatable>
                </div>
            </template>
        </div>
    </lightning-card>
</template>
```

