/*
* @author: Tumish TaK <tumish.tak@cognizant.com>
* @createdDate: 22-Sep-2021
* @lastModifiedBy: Tumish TaK <tumish.tak@cognizant.com>
* @lastModifiedDate: 23-Sep-2021
*/
public with sharing class OrderProductListController {

    /*auraMethod to return orderItems to LWC wire call- OrderProductList.js
      addedby: Tumish Tak on 22-Sep-2021 */
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(id selectedOrderid) {
       //Returing list of existing orderItems of provided OrderID 
       try{ return [SELECT Id, Quantity, Product2Id, Product2.Name, UnitPrice, TotalPrice, Order.Status 
                    FROM OrderItem
                    WHERE OrderId =:selectedOrderid
                    WITH SECURITY_ENFORCED];
       }
       catch(Exception e){
           throw new AuraHAndledException(e.getmessage());
       }
    }

     /*auraMethod to upsert OrderItems. Imperative call from LWC - OrderProductList.js
       addedby: Tumish Tak on 22-Sep-2021 */
    @AuraEnabled
    public static void upsertOrderItem(id pbeIDparam,id orderIdparam,double listPriceparam ){
        try {  
            //Fetch list of existing orderitems. 
            //If exists then increment the quantity by +1 else insert new orderitem.
            List<OrderItem> orderItemList = [Select Id,Quantity 
                                            from OrderItem 
                                            where OrderID =:orderIdparam 
                                            and PriceBookEntryId =:pbeIDparam
                                            WITH SECURITY_ENFORCED 
                                            LIMIT 1];
            if(!orderItemList.isEmpty()){
                orderItemList[0].Quantity += 1;
                update orderItemList;
            }
            else{
                OrderItem insrtOrdItem = new OrderItem();
                insrtOrdItem.Quantity = 1;
                insrtOrdItem.PriceBookEntryId = pbeIDparam;
                insrtOrdItem.OrderID = orderIdparam;
                insrtOrdItem.UnitPrice = listPriceparam;
                insert insrtOrdItem;
            }
            
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
            List<Order> orderList = [select id,Status 
                                    from Order 
                                    where id=:orderIdparam
                                    WITH SECURITY_ENFORCED];

            if(!(orderList.isEmpty()) && orderList[0].Status == 'Draft'){
                orderList[0].Status='Activated';
                update orderList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
