import { LightningElement, api, wire, track } from 'lwc';
import { updateRecord, getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import getProductList from '@salesforce/apex/ProductListController.getProductList';
import ORDER_OBJECT from '@salesforce/schema/Order';
import ORDER_STATUS_FIELD from '@salesforce/schema/Order.Status';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;
// declaring constant properties and their attributes. **********************
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
// declaration of constants ENDs here *****************************************

//Definition of default LWC class BEGINs***************************************
export default class ProductsList extends LightningElement {

 //property declaration ******************************************************* 
    @api recordId;
    @api record;
    @track productList;
    @track error;
    @track columns = COLUMNS; 
    @track orderStatus;
    @track searchDisabled;   
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    addedPBEid;
    selectedProdPrice;
    searchKey = '';
//property declaration ENDs here *********************************************    
 
//LDS wire service to get current ORDER status to determine ENABLE/DISABLE AddOrder button.
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
//LDS wire ENDs here**********************************************************

//wired call to apex method of class ProductListController to get priceBookentries to show in Table
// Passing orderStatus as reactive so that it is chained to the previous wired call (defined just above)   
@wire (getProductList, {orderIdparam:  '$recordId', orderStatusparam: '$orderStatus', searchKey: '$searchKey'}) 
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
            // Enable-Disable logic for Search bar    
                if(this.orderStatus==='Activated'){
                    this.searchDisabled = true;
                }
                else{
                    this.searchDisabled = false; 
                }
        } else{
            this.error = result.error;
            this.productList =  undefined;
        }
    }
//wired call ENDs here *******************************************************************

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
        const cloneData = [...this.productList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.productList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
// Sorting logic ENDs here *****************************************************

//Calling child LWC method addProduct and passing priceBookEntryId and productListPrice on click of Add Product button
    handleRowAction(event) {
        this.addedPBEid = event.detail.row.Id;
        this.selectedProdPrice = event.detail.row.UnitPrice;
        this.template.querySelector("c-order-product-list").addProduct(this.addedPBEid, this.selectedProdPrice);
    }
//handleRowAction method ENDs here **********************************************

//This method is called form child LWC orderProduct when user click on Activate Order button
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
            this.searchDisabled = true;
            // Notify LDS about the Order Status Change to refresh detail page.
            getRecordNotifyChange([{recordId: this.recordId}]);
    }
// handleStatusChange method ENDs here************************************************

    handleKeyChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY); 
    }
}
//Definition of default class ENDs here