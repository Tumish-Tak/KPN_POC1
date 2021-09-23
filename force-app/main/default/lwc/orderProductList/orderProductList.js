import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOrderProducts from '@salesforce/apex/OrderProductListController.getOrderProducts';
import upsertOrderItem from '@salesforce/apex/OrderProductListController.upsertOrderItem';
import activateOrder from '@salesforce/apex/OrderProductListController.activateOrder';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// declaring constant properties and their attributes. **********************
const COLUMNS = [
    {label:  'Product Name' , fieldName:  'ProductName' , type:  'text', sortable: true},   
    {label:  'Unit Price' , fieldName:  'UnitPrice' , type:  'currency', sortable: true},
    {label:  'Quantity' , fieldName:  'Quantity' , type:  'number', sortable: true},   
    {label:  'Total Price' , fieldName:  'TotalPrice' , type:  'currency', sortable: true}
];
// declaration of constants ENDs here *****************************************

//Definition of default LWC class BEGINs***************************************
export default class OrderProductList extends LightningElement {
    
//property declaration ******************************************************* 
    @api orderId;
    @api status;
    @track priceBookEntryId;
    @track selectedprodPrice;
    @track orderProducts;
    @track error;
    @track columns = COLUMNS;
    @track disableActivateButton = false;
    wiredOrderProducts;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
//property declaration ENDs here *********************************************    

//wire to apex class OrderProductListcontroller to get existing Orderitems ************
    @wire (getOrderProducts, {selectedOrderid: '$orderId'})
    WireOrderProductRecords(result){
        this.wiredOrderProducts=result;
        if(result.data){
            let preparedOrderItems = [];
            result.data.forEach(orderItemRec =>{
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
             //Checking whether to set Activate Order button to Enabled or Disabled 
             if(result.data[0].Order.Status==='Activated'){
                this.disableActivateButton = true;
            }
        } else{
            this.error = result.error;
            this.orderProducts =  undefined;
        }
    }
//wire to OrderProductListController ENDs here ************************************* 

// Standard lightningDataTable component logic for sorting cloumns ********************
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
// Sorting logic ENDs here *****************************************************

//Public method which gets called from parent LWC "productList"- "handleRowAction" method.
//This method does imperative call to OrderProductListcontroller class for upsert of OrderItems.
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
                  //Show Success message toast                     
                  const addProductEvent = new ShowToastEvent({
                    title:'Success!',
                    message:'OrderProduct added successfully',
                    variant:'success'
                  });
                  this.dispatchEvent(addProductEvent);
                  //Refresh orderProductList table after successful upsert operation
                  return refreshApex(this.wiredOrderProducts); 
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' + 'message ' + error.body.message;
        });
    }
//Public method addProduct ENDs here ******************************************

//This method is called upon Activate Order button click. 
//Also used to disable Activate Order button after activation.******************
    handleActivateOrder(){
        activateOrder({
            orderIdparam: this.orderId
        })
        .then(() => {         
                  const activateOrderEvent = new ShowToastEvent({
                    title:'Success!',
                    message:'Order Activated Successfully',
                    variant:'success'
                  });
                  this.dispatchEvent(activateOrderEvent);
            
            //Disabling Activate Order Button      
                  this.disableActivateButton = true; 

            //Firing event from child to parent to pass OrderStatus value
                  this.status = 'Activated';
                  const selectedEvent = new CustomEvent("statuschange", {
                    detail:this.status 
                  });              
                  this.dispatchEvent(selectedEvent);                   
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' + 'message ' + error.body.message;
        });
    }
//handleActivateOrder method ENDs here *****************************************
}
//default class definition EDNs here********************************************