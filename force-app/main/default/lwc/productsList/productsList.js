import { LightningElement, api, wire, track } from 'lwc';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import getProductList from '@salesforce/apex/ProductListController.getProductList';
import ORDER_OBJECT from '@salesforce/schema/Order';
import ORDER_STATUS_FIELD from '@salesforce/schema/Order.Status';

const COLUMNS = 
[
    {label:  'Product Name' , fieldName:  'ProductName' , type:  'text', sortable: true},   
    {label:  'List Price' , fieldName:  'UnitPrice' , type:  'currency', sortable: true},
    {type: "button", typeAttributes: {  
        label: 'Add Product',  
        name: 'AddProduct',  
        title: 'Add Product',  
        disabled: {fieldName: 'disableButton'},  
        value: 'addProduct',
        variant: 'brand',
        iconPosition: 'right'
    }}   
];

export default class ProductsList extends LightningElement {
    @api recordId;
    @api record;
    @track productList;
    @track error;
    @track columns = COLUMNS;    
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    addedPBEid;
    selectedProdPrice;
    @track orderStatus;
    
    @wire(getRecord, {recordId:'$recordId', fields: [ORDER_STATUS_FIELD]})
    wiredOrder({ error, data }) {
        if (data) {
            this.record = data;
            this.orderStatus = this.record.fields.Status.value;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    @wire (getProductList, {orderid:  '$recordId', orderStatusparam: '$orderStatus'}) 
    WireProductRecords(result){
        if(result.data){
            let preparedProducts = [];
            result.data.forEach(prodtRec =>{
                let preparedProduct = {};
                preparedProduct.Id = prodtRec.Id;
                preparedProduct.ProductName = prodtRec.Product2.Name;
                preparedProduct.UnitPrice = prodtRec.UnitPrice;
                preparedProduct.disableButton = this.orderStatus==='Activated'? true : false;
                preparedProducts.push(preparedProduct);
            });
            this.productList = [...preparedProducts];           
            this.error =  undefined;
        } else{
            this.error = result.error;
            this.productList =  undefined;
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

    handleRowAction(event) {
        this.addedPBEid = event.detail.row.Id;
        this.selectedProdPrice = event.detail.row.UnitPrice;
        this.template.querySelector("c-order-product-list").addProduct(this.addedPBEid, this.selectedProdPrice);
    }

    handleStatusChange(event){
        this.orderStatus = event.detail;
        //Switching off the Add Order button by updating the disableButton field to true     
        let preparedProducts = [];
            this.productList.forEach(prodtRec =>{
                let preparedProduct = {};
                preparedProduct.Id = prodtRec.Id;
                preparedProduct.ProductName = prodtRec.ProductName;
                preparedProduct.UnitPrice = prodtRec.UnitPrice;
                preparedProduct.disableButton = true;
                preparedProducts.push(preparedProduct);
            });
            this.productList = [...preparedProducts]; 
            //updateRecord({fields: this.recordId});
    }
}