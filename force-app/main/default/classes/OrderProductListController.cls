public with sharing class OrderProductListController {
    
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(id selectedOrderid) {
       try{ return [Select Id, Quantity, Product2Id, Product2.Name, UnitPrice, TotalPrice 
                from OrderItem
                where OrderId =:selectedOrderid
                WITH SECURITY_ENFORCED];
       }
       catch(Exception e){
           throw new AuraHAndledException(e.getmessage());
       }
    }

    @AuraEnabled
    public static void upsertOrderItem(id pbeIDparam,id orderIdparam,double listPriceparam ){
        try {   
            List<OrderItem> orderItemList = [Select Id,Quantity 
                                            from OrderItem 
                                            where OrderID =:orderIdparam 
                                            and PriceBookEntryId =:pbeIDparam
                                            WITH SECURITY_ENFORCED 
                                            LIMIT 1];
            if(!orderItemList.isEmpty()){
                orderItemList[0].Quantity = (orderItemList[0].Quantity) + 1;
                update orderItemList;
            }
            else{
                system.debug('Inside else loop'+listPriceparam);
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
}
