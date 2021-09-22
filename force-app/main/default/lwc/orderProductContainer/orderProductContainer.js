import { LightningElement, track, api, wire } from 'lwc';
import getOrderItem from '@salesforce/apex/OrderProductController.getOrderItem';
import activateOrder from '@salesforce/apex/OrderProductController.activateOrder';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { updateRecord } from 'lightning/uiRecordApi';

export default class OrderProductContainer extends LightningElement {
    @track products;
    @track error;
    @api recordId;
    @track disabled;
    @track order;
    @track columns = [
        { label: 'Name', fieldName: 'Name',sortable: "true" },
        { label: 'Unit Price', fieldName: 'UnitPrice',sortable: "true" },
        { label: 'Quantity', fieldName: 'Quantity',sortable: "true" },
        { label: 'Total Price', fieldName: 'TotalPrice',sortable: "true" }

    ];
    @wire(getRecord, { recordId: '$recordId', fields: ['Order.Id', 'Order.Status', 'Order.AccountId'] })
    getOrderRecord({ data, error }) {
        if (data) {
            this.order = data;
            if(this.order.fields.Status.value == 'Activated') {
                this.disabled = true;
            } else {
                this.disabled = false;
            }
            this.processRelatedObjects();
            this.connectedCallback();
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }
    processRelatedObjects() {
        console.log('processRelatedObjects for => ', JSON.stringify(this.order));
        // further processing like refreshApex or calling another wire service
    }
    connectedCallback() {
        getOrderItem({ orderId: this.recordId })
            .then(result => {
                let resultProduct = JSON.parse(result)
                this.products = resultProduct;
            })
            .catch(error => {
                console.log('errror ', error)
            })
    }

    activate() {
        activateOrder({ orderId: this.recordId })
            .then(result => {
                let response = JSON.parse(result);
                const evt = new ShowToastEvent({
                    title: response.message,
                    message: 'Success',
                    variant: 'Success',
                });
                this.dispatchEvent(evt);
                updateRecord({ fields: { Id: this.recordId } });

            })
            .catch(error => {
                console.log('errror ', error)
                let errorResponse = JSON.parse(error);
                const evt = new ShowToastEvent({
                    title: errorResponse.message,
                    message: 'Error',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
            })
    }

}