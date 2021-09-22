public with sharing class OrderProductListController {
    @AuraEnabled(cacheable=true)
    public static List<OrderItem> getOrderProducts(id selectedOrderid) {
        return [Select Id, Quantity, Product2Id, Product2.Name, UnitPrice, TotalPrice 
                from OrderItem
                where OrderId =:selectedOrderid
                WITH SECURITY_ENFORCED];
    }
}
