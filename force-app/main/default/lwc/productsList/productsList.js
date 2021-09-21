import { LightningElement, api, wire, track } from 'lwc';
import getProductList from '@salesforce/apex/ProductListController.getProductList';
const COLUMNS = [
    {label:  'Name' , fieldName:  'ProductName' , type:  'text', sortable: true},
    {label:  'List Price' , fieldName:  'UnitPrice' , type:  'currency', sortable: true}       
];

export default class ProductsList extends LightningElement {
    @api recordId;
    @track productList;
    @track columns = COLUMNS;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    @wire (getProductList, {orderid:  '$recordId' }) 
    WireProductRecords({error, data}){
        if(data){
            let preparedProducts = [];
            data.forEach(prodtRec =>{
                let preparedProduct = {};
                preparedProduct.id = prodtRec.Product2ID;
                preparedProduct.ProductName = prodtRec.Product2.Name;
                preparedProduct.UnitPrice = prodtRec.UnitPrice;
                preparedProducts.push(preparedProduct);
            });
            this.productList = preparedProducts;
            this.error =  undefined ;
        } else{
            this.error = error;
            this.productList =  undefined ;
        }
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.productList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.productList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}