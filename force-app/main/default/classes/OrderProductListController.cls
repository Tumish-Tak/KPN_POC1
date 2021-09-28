/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 22-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 28-Sep-2021
* @description: This class acts as a busniess logic layer class for the LWC - orderProductList
*/
public with sharing class OrderProductListController {

    /*auraMethod to return orderItems to LWC wire call- OrderProductList.js
      addedby: Tumish Tak on 22-Sep-2021 */
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(id selectedOrderid) {
       //Returing list of existing orderItems of provided OrderID 
       try{ 
           List<OrderItem> orderItemList = OrderProductListDataService.getOrderProductDetails(selectedOrderid);
           return orderItemList;
        }
       catch(Exception e){
           throw new AuraHandledException(e.getmessage());
       }
    }

     /*auraMethod to upsert OrderItems. Imperative call from LWC - OrderProductList.js
       addedby: Tumish Tak on 22-Sep-2021 */
    @AuraEnabled
    public static List<OrderItem> upsertOrderItem(id pbeIDparam,id orderIdparam,double listPriceparam){
        try {  
            //Fetch list of existing orderitems. 
            //If exists then increment the quantity by +1 else insert new orderitem.
            List<OrderItem> orderItemList = OrderProductListDataService.getExistingOrderProduct(pbeIDparam, orderIdparam, listPriceparam);
            
            if(!orderItemList.isEmpty()){
                orderItemList[0].Quantity += 1;
                update orderItemList;
            }
            //Else inserting a new OrderItem for the provided OrderID
            else{
                OrderItem insrtOrdItem = new OrderItem();
                insrtOrdItem.Quantity = 1;
                insrtOrdItem.PriceBookEntryId = pbeIDparam;
                insrtOrdItem.OrderID = orderIdparam;
                insrtOrdItem.UnitPrice = listPriceparam;
                insert insrtOrdItem;
            }
        
            //Getting updated orderItem's list
            List<OrderItem> updatedOrderItemList =  OrderProductListDataService.getOrderProductDetails(orderIdparam);
            return updatedOrderItemList;            
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     /*auraMethod to Activate Order. Imperative call from LWC - OrderProductList.js
       addedby: Tumish Tak on 23-Sep-2021 */
    @AuraEnabled
    public static void activateOrder(id orderIdparam){
        try {
        //Set the Order Status to 'Activated' on Activate Order button click from LWC - OrderProductList
            List<Order> orderList = OrderProductListDataService.getOrderDetails(orderIdparam);
        
            if(!(orderList.isEmpty()) && orderList[0].Status == 'Draft'){
                orderList[0].Status='Activated';
                update orderList;
            }            
        }        
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
