import { LightningElement, api, track } from 'lwc';


export default class AvailabelProductTable extends LightningElement {

    @api columns;
    @api productsShow;
    @track orderRow;
    @api originalData
    @track isInit
    handleRowAction(event) {
        const dataRow = event.detail.row;
        this.orderRow = dataRow;
        const upsertEvent = new CustomEvent('action', { detail: this.orderRow.Id });
        this.dispatchEvent(upsertEvent);
    }
    handleSearch(event) {
        this.productsShow = event.detail
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.productsShow));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.productsShow = parseData;
    }

}