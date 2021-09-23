import { LightningElement, wire, track, api } from 'lwc';
import getProducts from '@salesforce/apex/AvailableProductController.getProducts';
import upsertProduct from '@salesforce/apex/AvailableProductController.upsertOrderLineItem';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class AvailableProductContainer extends LightningElement {
    @track products;
    @track error;
    @track order;
    @track disabled;
    @track isLoading;
    @api recordId;
    @track columns = [
        { label: 'Name', fieldName: 'Name', sortable: true },
        { label: 'List Price', fieldName: 'UnitPrice', sortable: true },
        {
            type: "button",
            fixedWidth: 150,
            typeAttributes: {
                label: 'Add Product',
                title: 'Add Product',
                name: 'AddProduct',
                value: 'AddProduct',
                variant: 'brand',
                disabled: false
            }
        }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: ['Order.Id', 'Order.Status', 'Order.AccountId'] })
    getOrderRecord({ data, error }) {
        if (data) {
            this.order = data;
            if (this.order.fields.Status.value == 'Activated') {
                this.columns[2].typeAttributes.disabled = true;
            } else {
                this.columns[2].typeAttributes.disabled = false;
            }
            this.connectedCallback();
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }
    connectedCallback() {
        this.isLoading = true;
        getProducts({ orderId: this.recordId })
            .then(result => {
                
                this.products = result;
                console.log('PRODUCTS', this.products);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                console.log('errror ', error)
            })
    }
    handleUpsert(event) {
        this.isLoading = true;
        upsertProduct({ priceBookEntryId: event.detail, orderId: this.recordId })
            .then(result => {
                const evt = new ShowToastEvent({
                    title: result.message,
                    message: 'Success',
                    variant: 'Success',
                });
                this.dispatchEvent(evt);
                updateRecord({ fields: { Id: this.recordId } });
                this.isLoading = false;

            })
            .catch(error => {
                console.log('errror ', error)
                const evt = new ShowToastEvent({
                    title: 'error',
                    message: 'Error',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
                this.isLoading = false;


            })
    }

}