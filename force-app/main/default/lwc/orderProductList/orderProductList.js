import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOrderProducts from '@salesforce/apex/OrderProductListController.getOrderProducts';
import upsertOrderItem from '@salesforce/apex/OrderProductListController.upsertOrderItem';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
const COLUMNS = [
    {label:  'Product Name' , fieldName:  'ProductName' , type:  'text', sortable: true},   
    {label:  'Unit Price' , fieldName:  'UnitPrice' , type:  'currency', sortable: true},
    {label:  'Quantity' , fieldName:  'Quantity' , type:  'number', sortable: true},   
    {label:  'Total Price' , fieldName:  'TotalPrice' , type:  'currency', sortable: true}
];
export default class OrderProductList extends LightningElement {
    @api orderId;
    @track priceBookEntryId;
    @track selectedprodPrice;
    @track orderProducts;
    @track error;
    @track columns = COLUMNS;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    @wire (getOrderProducts, {selectedOrderid: '$orderId'})
    WireOrderProductRecords({error, data}){
        if(data){
            this.orderProducts=data;
            let preparedOrderItems = [];
            data.forEach(orderItemRec =>{
                let preparedItem = {};
                preparedItem.Id = orderItemRec.Id;
                preparedItem.ProductName = orderItemRec.Product2.Name;
                preparedItem.UnitPrice = orderItemRec.UnitPrice;
                preparedItem.Quantity = orderItemRec.Quantity;
                preparedItem.TotalPrice = orderItemRec.TotalPrice;
                preparedOrderItems.push(preparedItem);
            });
            this.orderProducts = [...preparedOrderItems];
            this.error =  undefined;
        } else{
            this.error = error;
            this.orderProducts =  undefined;
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
        const cloneData = [...this.orderProducts];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.orderProducts = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    @api addProduct(childPBEid, productPrice){  
        this.priceBookEntryId = childPBEid;
        this.selectedprodPrice = productPrice;
        console.log("OrderID is - "+this.orderId+" and PBEID is - "+this.priceBookEntryId+" and price is :- "+this.selectedprodPrice);
        upsertOrderItem({
            pbeIDparam: this.priceBookEntryId,
            orderIdparam: this.orderId,
            listPriceparam: this.selectedprodPrice
        })
        .then(() => {
            refreshApex(this.orderProducts);           
                const toastEvent = new ShowToastEvent({
                    title:'Success!',
                    message:'Order Product added successfully',
                    variant:'success'
                  });
                  this.dispatchEvent(toastEvent);
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }
}