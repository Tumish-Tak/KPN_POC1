import { LightningElement, api, wire, track } from 'lwc';
import getProductList from '@salesforce/apex/ProductListController.getProductList';
const COLUMNS = [
    {label:  'Name' , fieldName:  'ProductName' , type:  'text'},
    {label:  'List Price' , fieldName:  'UnitPrice' , type:  'currency'}       
]; 
export default class ProductsList extends LightningElement {
    @api recordId;
    @track productList;
    @track columns = COLUMNS;

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
}