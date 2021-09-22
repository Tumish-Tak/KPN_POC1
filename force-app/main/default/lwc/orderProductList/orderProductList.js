import { LightningElement, api, track, wire } from 'lwc';
import getOrderProducts from '@salesforce/apex/OrderProductListController.getOrderProducts';
const COLUMNS = [
    {label:  'Product Name' , fieldName:  'ProductName' , type:  'text', sortable: true},   
    {label:  'Unit Price' , fieldName:  'UnitPrice' , type:  'currency', sortable: true},
    {label:  'Quantity' , fieldName:  'Quantity' , type:  'number', sortable: true},   
    {label:  'Total Price' , fieldName:  'TotalPrice' , type:  'currency', sortable: true}
];
export default class OrderProductList extends LightningElement {
    @api orderId;
    @track orderProducts;
    @track error;
    @track columns = COLUMNS;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    @wire (getOrderProducts, {selectedOrderid: '$orderId'})
    WireOrderProductRecords({error, data}){
        if(data){
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
            this.orderProducts = preparedOrderItems;
            this.error =  undefined ;
        } else{
            this.error = error;
            this.orderProducts =  undefined ;
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
}