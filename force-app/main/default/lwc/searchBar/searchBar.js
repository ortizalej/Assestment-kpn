import { LightningElement, track, api } from 'lwc';
export default class SearchBar extends LightningElement {
    @track searchValue;
    @api searchData;
    searchKeyword(event) {
        this.searchValue = event.target.value;
        let filteredData = this.searchData.filter(function (currentItem) {
            if(currentItem.Name.toLocaleLowerCase().indexOf(event.target.value.toLocaleLowerCase()) >= 0) {
                return currentItem;
            }
        });
        const sentDataEvt = new CustomEvent('search', { detail: filteredData });
        this.dispatchEvent(sentDataEvt);
    }

}