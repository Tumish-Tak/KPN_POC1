import { LightningElement, api, wire, track } from 'lwc';
import getProductList from '@salesforce/apex/ProductListController.getProductList';
export default class ProductsList extends LightningElement {
    @api recordId;
    @track productList;
    @track columns = [
        {label:  'Name' , fieldName:  'Product2.Name' , type:  'text'  },
        {label:  'List Price' , fieldName:  'UnitPrice' , type:  'currency'  }
    ];

    @wire (getProductList, {orderid:  '$ recordId' }) 
    WireProductRecords ({error, data}) {
        if (data) {
            this.productList = data;
            this.error =  undefined ;
        } else {
            this.error = error;
            this.productList =  undefined ;
        }
    }
}